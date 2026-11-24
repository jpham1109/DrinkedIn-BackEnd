require 'rails_helper'

# ai/v1-redesign-plan.md's privacy-first-user-discovery workstream
# (2026-11-23), Step 1 — AccountSerializer's followed_users/
# following_users gain nested follower/followee identity, additive to
# the existing bare Follow fields. Covers every AccountSerializer call
# site (GET /me, POST /login, PATCH /me) since all three share the same
# overridden serializer methods.
RSpec.describe 'AccountSerializer follow identities', type: :request do
  def published_creator(category: create(:category))
    creator = create(:user)
    create(:cocktail, :published, submitted_by: creator, creator_unknown: true, category:)
    creator
  end

  describe 'nested identity resolves to the other participant, never the current account' do
    it 'on GET /me: followed_users nests the followee, following_users nests the follower' do
      account_a = create(:user)
      account_b = published_creator
      account_c = create(:user)
      create(:follow, follower: account_a, followee: account_b) # A follows B
      create(:follow, follower: account_c, followee: account_a) # C follows A

      get '/me', headers: auth_headers_for(account_a)

      body = JSON.parse(response.body)['data']
      followed_entry = body['followed_users'].first
      following_entry = body['following_users'].first

      expect(followed_entry['followee']['id']).to eq(account_b.id)
      expect(followed_entry['followee']['id']).not_to eq(account_a.id)
      expect(followed_entry['followee']['id']).not_to eq(account_c.id)

      expect(following_entry['follower']['id']).to eq(account_c.id)
      expect(following_entry['follower']['id']).not_to eq(account_a.id)
      expect(following_entry['follower']['id']).not_to eq(account_b.id)
    end

    it 'nests the correct identity shape (id, full_name, username, location, avatar) matching BartenderSerializer' do
      account_a = create(:user)
      account_b = published_creator

      create(:follow, follower: account_a, followee: account_b)

      get '/me', headers: auth_headers_for(account_a)

      followee = JSON.parse(response.body).dig('data', 'followed_users', 0, 'followee')
      expect(followee.keys).to match_array(%w[id full_name username location avatar])
      expect(followee['username']).to eq(account_b.username)
    end
  end

  describe 'backward compatibility: existing Follow fields are unchanged' do
    it 'preserves id, follower_id, followee_id on every enriched entry' do
      account_a = create(:user)
      account_b = published_creator
      account_c = create(:user)
      followed = create(:follow, follower: account_a, followee: account_b)
      following = create(:follow, follower: account_c, followee: account_a)

      get '/me', headers: auth_headers_for(account_a)

      body = JSON.parse(response.body)['data']
      followed_entry = body['followed_users'].first
      following_entry = body['following_users'].first

      expect(followed_entry.values_at('id', 'follower_id', 'followee_id'))
        .to eq([followed.id, account_a.id, account_b.id])
      expect(following_entry.values_at('id', 'follower_id', 'followee_id'))
        .to eq([following.id, account_c.id, account_a.id])
    end

    it 'POST /login returns the same enriched shape' do
      account_a = create(:user, password: 'password123')
      account_b = published_creator
      create(:follow, follower: account_a, followee: account_b)

      csrf_token = fetch_csrf_token
      post '/login', params: { session: { username: account_a.username, password: 'password123' } },
                     headers: { 'X-CSRF-Token' => csrf_token }

      followee = JSON.parse(response.body).dig('data', 'user', 'followed_users', 0, 'followee')
      expect(followee['id']).to eq(account_b.id)
    end

    it "PATCH /me's own response returns the same enriched shape" do
      account_a = create(:user)
      account_b = published_creator
      create(:follow, follower: account_a, followee: account_b)

      patch '/me', params: { user: { full_name: 'New Name' } }, headers: auth_headers_for(account_a)

      followee = JSON.parse(response.body).dig('followed_users', 0, 'followee')
      expect(followee['id']).to eq(account_b.id)
    end
  end

  describe 'legacy-data safeguard: a followee that fails User.followable' do
    it 'renders the entry with no nested followee key at all, not a null one' do
      account_a = create(:user)
      private_account = create(:user) # no published cocktail — not followable
      create(:follow, follower: account_a, followee: private_account)

      get '/me', headers: auth_headers_for(account_a)

      followed_entry = JSON.parse(response.body).dig('data', 'followed_users', 0)
      expect(followed_entry).not_to have_key('followee')
      expect(followed_entry.values_at('follower_id', 'followee_id')).to eq([account_a.id, private_account.id])
    end

    it 'does not withhold the follower nested identity on the following_users side, regardless of eligibility' do
      account_a = create(:user)
      private_follower = create(:user) # no published cocktail — still a legitimate follower
      create(:follow, follower: private_follower, followee: account_a)

      get '/me', headers: auth_headers_for(account_a)

      following_entry = JSON.parse(response.body).dig('data', 'following_users', 0)
      expect(following_entry['follower']['id']).to eq(private_follower.id)
    end
  end

  # Matches this codebase's own established N+1-proof pattern
  # (spec/requests/cocktails_spec.rb's "users" query-count test) —
  # scaling the number of follows must not scale the query count.
  describe 'N+1 safety' do
    it 'resolves nested identities across many follows with a query count independent of N' do
      account_a = create(:user)
      category = create(:category)

      count_queries_for = lambda do
        query_count = 0
        counter = lambda do |_name, _started, _finished, _id, payload|
          next if payload[:name] == 'SCHEMA' || payload[:cached]

          query_count += 1
        end
        ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') do
          get '/me', headers: auth_headers_for(account_a)
        end
        query_count
      end

      create(:follow, follower: account_a, followee: published_creator(category:))
      create(:follow, follower: create(:user), followee: account_a)
      baseline_count = count_queries_for.call

      8.times do
        create(:follow, follower: account_a, followee: published_creator(category:))
        create(:follow, follower: create(:user), followee: account_a)
      end
      scaled_up_count = count_queries_for.call

      body = JSON.parse(response.body)['data']
      expect(body['followed_users'].count).to be >= 9
      expect(body['following_users'].count).to be >= 9
      expect(body['followed_users'].all? { |e| e.key?('followee') }).to be true
      expect(body['following_users'].all? { |e| e.key?('follower') }).to be true

      expect(scaled_up_count).to eq(baseline_count)
    end
  end
end

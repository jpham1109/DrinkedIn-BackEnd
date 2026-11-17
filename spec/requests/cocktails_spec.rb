require 'rails_helper'

RSpec.describe 'Cocktails', type: :request do
  describe 'GET /cocktails' do
    it 'returns 200 with a data array' do
      get '/cocktails'
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key('data')
      expect(body['data']).to be_an(Array)
    end

    it 'does not include meta when there is no pagination' do
      get '/cocktails'
      body = JSON.parse(response.body)
      expect(body).not_to have_key('meta')
    end

    # ai/v1-redesign-plan.md's creator/submitter attribution workstream,
    # B3: resolving each cocktail's registered creator must stay a single
    # preloaded batch query, not one query per cocktail — proven by
    # counting SQL queries against a database with several distinct
    # creators, not just asserted from reading the includes() call.
    #
    # Scoped to queries against the "users" table specifically: a
    # separate, pre-existing N+1 on `image_attachment: :blob` (one
    # `active_storage_attachments` query per cocktail regardless of
    # whether an image is attached — confirmed via a live query trace,
    # present before this PR's changes, unrelated to creator/submitter
    # attribution) would otherwise swamp this measurement. That one is
    # out of scope here — flagged separately, not fixed in this PR.
    it 'resolves registered creators across the collection with a "users" query count independent of N' do
      submitter = create(:user)
      category = create(:category)

      count_user_queries_for = lambda do
        query_count = 0
        counter = lambda do |_name, _started, _finished, _id, payload|
          next if payload[:name] == 'SCHEMA' || payload[:cached]

          query_count += 1 if payload[:sql].include?('FROM "users"')
        end
        ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') { get '/cocktails' }
        query_count
      end

      create(:cocktail, submitted_by: submitter, creator_user: create(:user), category:)
      baseline_count = count_user_queries_for.call

      create_list(:user, 8).each do |creator|
        create(:cocktail, submitted_by: submitter, creator_user: creator, category:)
      end
      scaled_up_count = count_user_queries_for.call

      data = JSON.parse(response.body)['data']
      expect(data.count { |c| c['creator'].present? }).to be >= 9
      # The real N+1 proof: going from 1 cocktail-with-creator to 9 must
      # not multiply the "users" query count — a per-cocktail creator
      # lookup would scale with N; a single preloaded batch query does
      # not (submitted_by and creator_user each contribute at most one
      # query regardless of how many distinct users are involved).
      expect(scaled_up_count).to eq(baseline_count)
    end
  end

  describe 'GET /cocktails/:id' do
    let(:owner) { create(:user) }
    let(:cocktail) { create(:cocktail, submitted_by: owner) }

    it 'returns 200 with a data object' do
      get "/cocktails/#{cocktail.id}"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key('data')
    end

    # Exposed for deterministic client-side ranking (e.g. Home's featured-
    # cocktail tie-break: likes_count desc, then created_at desc, then id) —
    # previously only likes_count/id were available, with no way to order by
    # recency at all.
    it 'includes created_at' do
      get "/cocktails/#{cocktail.id}"
      body = JSON.parse(response.body)
      expect(body['data']['created_at']).to be_present
    end

    # ai/v1-redesign-plan.md's creator/submitter attribution workstream,
    # B3's "additive-then-remove" API transition strategy: the legacy
    # bartender/bartender_id keys must keep returning exactly what they
    # always have (now backed by the renamed submitted_by association),
    # while the new keys appear alongside them — never a bare rename in
    # one deploy.
    it 'exposes both the legacy bartender keys and the new submitted_by/creator keys with matching values' do
      get "/cocktails/#{cocktail.id}"
      data = JSON.parse(response.body)['data']
      expect(data['bartender_id']).to eq(owner.id)
      expect(data['bartender']['id']).to eq(owner.id)
      expect(data['submitted_by_id']).to eq(owner.id)
      expect(data['submitted_by']['id']).to eq(owner.id)
      expect(data).to have_key('creator_user_id')
      expect(data).to have_key('creator_name')
      expect(data['creator_unknown']).to eq(false)
    end

    it 'resolves a registered creator to a nested object with name/avatar/location fields' do
      creator = create(:user, full_name: 'Dale DeGroff', location: 'New York, NY')
      cocktail_with_creator = create(:cocktail, submitted_by: owner, creator_user: creator)

      get "/cocktails/#{cocktail_with_creator.id}"
      data = JSON.parse(response.body)['data']
      expect(data['creator']['id']).to eq(creator.id)
      expect(data['creator']['full_name']).to eq('Dale DeGroff')
      expect(data['creator']['location']).to eq('New York, NY')
      expect(data['creator']).to have_key('avatar')
    end

    # Confirms BartenderSerializer (shared by bartender/submitted_by/
    # creator) exposes exactly the intended public identity fields —
    # nothing sensitive (password_digest, the bartender boolean flag,
    # etc.) ever leaks through, since AMS `attributes` is an explicit
    # whitelist, not reflection over the model's columns.
    it 'exposes only the intended public identity fields on every registered-person object' do
      creator = create(:user)
      cocktail_with_creator = create(:cocktail, submitted_by: owner, creator_user: creator)

      get "/cocktails/#{cocktail_with_creator.id}"
      data = JSON.parse(response.body)['data']
      expected_keys = %w[id full_name username location avatar]
      expect(data['creator'].keys).to match_array(expected_keys)
      expect(data['bartender'].keys).to match_array(expected_keys)
      expect(data['submitted_by'].keys).to match_array(expected_keys)
    end

    it 'returns a null creator when no registered creator is linked' do
      get "/cocktails/#{cocktail.id}"
      data = JSON.parse(response.body)['data']
      expect(data['creator']).to be_nil
    end
  end

  describe 'POST /cocktails' do
    let(:user) { create(:user) }
    let(:category) { create(:category) }
    let(:valid_params) do
      { cocktail: { name: 'Old Fashioned', description: 'A classic', execution: 'Stir well',
                    ingredients: 'whiskey,bitters,sugar', category_id: category.id } }
    end

    context 'when unauthenticated' do
      it 'returns 401 with authentication_required error' do
        post '/cocktails', params: valid_params
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('authentication_required')
        expect(body['errors'][0]['message']).to be_present
      end
    end

    context 'when authenticated' do
      it 'creates a cocktail and returns 201 with data' do
        post '/cocktails', params: valid_params, headers: auth_headers_for(user)
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body).to have_key('data')
        expect(Cocktail.last.submitted_by_id).to eq(user.id)
      end

      it 'ignores a spoofed user_id param' do
        other_user = create(:user)
        post '/cocktails', params: valid_params.deep_merge(cocktail: { user_id: other_user.id }),
                           headers: auth_headers_for(user)
        expect(response).to have_http_status(:created)
        expect(Cocktail.last.submitted_by_id).to eq(user.id)
      end

      it 'accepts an explicit creator_name distinct from the submitter' do
        post '/cocktails', params: valid_params.deep_merge(cocktail: { creator_name: 'Dale DeGroff' }),
                           headers: auth_headers_for(user)
        expect(response).to have_http_status(:created)
        expect(Cocktail.last.creator_name).to eq('Dale DeGroff')
        expect(Cocktail.last.creator_user_id).to be_nil
      end

      it 'accepts an explicit creator_unknown flag' do
        post '/cocktails', params: valid_params.deep_merge(cocktail: { creator_unknown: true }),
                           headers: auth_headers_for(user)
        expect(response).to have_http_status(:created)
        expect(Cocktail.last.creator_unknown).to be(true)
      end

      it 'rejects conflicting creator attribution with a 422' do
        creator = create(:user)
        post '/cocktails',
             params: valid_params.deep_merge(cocktail: { creator_user_id: creator.id, creator_name: 'Dale DeGroff' }),
             headers: auth_headers_for(user)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /cocktails/:id' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:cocktail) { create(:cocktail, submitted_by: owner) }

    context 'when unauthenticated' do
      it 'returns 401 with authentication_required error' do
        patch "/cocktails/#{cocktail.id}", params: { cocktail: { name: 'Updated' } }
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('authentication_required')
      end
    end

    context 'when authenticated as the owner' do
      it 'updates the cocktail and returns 200 with data' do
        patch "/cocktails/#{cocktail.id}", params: { cocktail: { name: 'Updated Name' } },
                                           headers: auth_headers_for(owner)
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body).to have_key('data')
      end
    end

    context 'when authenticated as a non-owner' do
      it 'returns 403 with forbidden error' do
        patch "/cocktails/#{cocktail.id}", params: { cocktail: { name: 'Hacked' } },
                                           headers: auth_headers_for(other_user)
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('forbidden')
        expect(body['errors'][0]['message']).to be_present
      end
    end

    # Direct proof that creator attribution (B2) grants no authorization:
    # being credited as a cocktail's *creator* must not let that user
    # edit a record someone else submitted/owns.
    context 'when authenticated as the credited creator but not the submitter' do
      it 'returns 403 with forbidden error' do
        creator = create(:user)
        cocktail_with_creator = create(:cocktail, submitted_by: owner, creator_user: creator)

        patch "/cocktails/#{cocktail_with_creator.id}", params: { cocktail: { name: 'Hacked' } },
                                                        headers: auth_headers_for(creator)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'photo upload validation' do
    let(:user) { create(:user) }
    let(:category) { create(:category) }
    let(:base_params) do
      { cocktail: { name: 'Sunset Spritz', description: 'Refreshing', execution: 'Shake',
                    ingredients: 'gin,tonic', category_id: category.id } }
    end

    context 'on POST /cocktails' do
      it 'rejects a non-image file with upload_invalid_type error' do
        post '/cocktails',
             params: base_params.deep_merge(cocktail: { photo: invalid_type_upload }),
             headers: auth_headers_for(user)
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('upload_invalid_type')
        expect(body['errors'][0]['message']).to be_present
      end

      it 'rejects a GIF with upload_invalid_type error' do
        post '/cocktails',
             params: base_params.deep_merge(cocktail: { photo: gif_upload }),
             headers: auth_headers_for(user)
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('upload_invalid_type')
      end

      it 'rejects an oversized file with upload_too_large error' do
        post '/cocktails',
             params: base_params.deep_merge(cocktail: { photo: oversized_upload }),
             headers: auth_headers_for(user)
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('upload_too_large')
        expect(body['errors'][0]['message']).to be_present
      end
    end

    context 'on PATCH /cocktails/:id' do
      let(:cocktail) { create(:cocktail, submitted_by: user) }

      it 'rejects a non-image file with upload_invalid_type error' do
        patch "/cocktails/#{cocktail.id}",
              params: { cocktail: { photo: invalid_type_upload } },
              headers: auth_headers_for(user)
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('upload_invalid_type')
      end

      it 'rejects an oversized file with upload_too_large error' do
        patch "/cocktails/#{cocktail.id}",
              params: { cocktail: { photo: oversized_upload } },
              headers: auth_headers_for(user)
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('upload_too_large')
      end
    end
  end

  describe 'background variant processing' do
    let(:user) { create(:user) }
    let(:category) { create(:category) }
    let(:base_params) do
      { cocktail: { name: 'Paloma', description: 'Bright and citrusy', execution: 'Build over ice',
                    ingredients: 'tequila,grapefruit soda', category_id: category.id } }
    end

    it 'enqueues ProcessImageVariantJob when a valid photo is uploaded on create' do
      expect do
        post '/cocktails',
             params: base_params.deep_merge(cocktail: { photo: valid_image_upload }),
             headers: auth_headers_for(user)
      end.to have_enqueued_job(ProcessImageVariantJob)
      expect(response).to have_http_status(:created)
    end

    it 'does not enqueue ProcessImageVariantJob when no photo is uploaded on create' do
      expect do
        post '/cocktails', params: base_params, headers: auth_headers_for(user)
      end.not_to have_enqueued_job(ProcessImageVariantJob)
    end

    it 'does not enqueue ProcessImageVariantJob when an invalid photo is rejected' do
      expect do
        post '/cocktails',
             params: base_params.deep_merge(cocktail: { photo: invalid_type_upload }),
             headers: auth_headers_for(user)
      end.not_to have_enqueued_job(ProcessImageVariantJob)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'enqueues ProcessImageVariantJob when a valid photo is uploaded on update' do
      cocktail = create(:cocktail, submitted_by: user)

      expect do
        patch "/cocktails/#{cocktail.id}",
              params: { cocktail: { photo: valid_image_upload } },
              headers: auth_headers_for(user)
      end.to have_enqueued_job(ProcessImageVariantJob)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE /cocktails/:id' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:cocktail) { create(:cocktail, submitted_by: owner) }

    context 'when unauthenticated' do
      it 'returns 401 with authentication_required error' do
        delete "/cocktails/#{cocktail.id}"
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('authentication_required')
      end
    end

    context 'when authenticated as the owner' do
      it 'destroys the cocktail with no content' do
        delete "/cocktails/#{cocktail.id}", headers: auth_headers_for(owner)
        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_empty
      end
    end

    context 'when authenticated as a non-owner' do
      it 'returns 403 with forbidden error' do
        delete "/cocktails/#{cocktail.id}", headers: auth_headers_for(other_user)
        expect(response).to have_http_status(:forbidden)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('forbidden')
      end
    end

    context 'when authenticated as the credited creator but not the submitter' do
      it 'returns 403 with forbidden error' do
        creator = create(:user)
        cocktail_with_creator = create(:cocktail, submitted_by: owner, creator_user: creator)

        delete "/cocktails/#{cocktail_with_creator.id}", headers: auth_headers_for(creator)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end

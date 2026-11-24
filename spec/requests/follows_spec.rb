require 'rails_helper'

RSpec.describe 'Follows', type: :request do
  # ai/v1-redesign-plan.md's privacy-first-user-discovery workstream
  # (2026-11-23), Step 3 — the real, legitimate flow (useFollowBartender.js)
  # always targets a cocktail's embedded, already-public bartender/
  # creator id, so every positive POST /follows example needs a target
  # that actually passes User.followable.
  def published_creator
    creator = create(:user)
    create(:cocktail, :published, submitted_by: creator, creator_unknown: true, category: create(:category))
    creator
  end

  describe 'POST /follows' do
    let(:user) { create(:user) }
    let(:target) { published_creator }

    context 'when unauthenticated' do
      it 'returns 401' do
        post '/follows', params: { followee_id: target.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      it 'creates a follow as current_user' do
        post '/follows', params: { followee_id: target.id }, headers: auth_headers_for(user)
        expect(response).to have_http_status(:ok)
        expect(Follow.last.follower_id).to eq(user.id)
      end

      it 'ignores a spoofed follower_id param' do
        other_user = create(:user)
        post '/follows', params: { follower_id: other_user.id, followee_id: target.id },
                         headers: auth_headers_for(user)
        expect(Follow.last.follower_id).to eq(user.id)
      end
    end

    # ai/v1-redesign-plan.md's privacy-first-user-discovery workstream
    # (2026-11-23), Step 3 — closes the enumeration gap found auditing
    # this action: before this fix, any authenticated account could
    # POST /follows with a guessed id and, if it succeeded, read that
    # id's identity back out through the enriched /me payload (Step 1)
    # and — under the pre-narrowing avatar rule — its avatar too,
    # regardless of whether the target ever consented to being
    # discoverable. User.followable (Step 1's scope, reused here) now
    # gates creation itself.
    describe 'target eligibility' do
      it 'rejects a nonexistent followee_id with 404' do
        post '/follows', params: { followee_id: 999_999 }, headers: auth_headers_for(user)
        expect(response).to have_http_status(:not_found)
        expect(Follow.count).to eq(0)
      end

      it 'rejects an existing-but-non-public-creator followee_id with 404' do
        private_account = create(:user)
        post '/follows', params: { followee_id: private_account.id }, headers: auth_headers_for(user)
        expect(response).to have_http_status(:not_found)
        expect(Follow.count).to eq(0)
      end

      it 'produces an identical rejection body for a nonexistent id and an existing-but-private id' do
        private_account = create(:user)

        post '/follows', params: { followee_id: 999_999 }, headers: auth_headers_for(user)
        nonexistent_status = response.status
        nonexistent_body = JSON.parse(response.body)

        post '/follows', params: { followee_id: private_account.id }, headers: auth_headers_for(user)
        private_status = response.status
        private_body = JSON.parse(response.body)

        expect(nonexistent_status).to eq(private_status)
        expect(nonexistent_body).to eq(private_body)
      end

      it 'still allows following the real, legitimate target: a published cocktail’s creator' do
        post '/follows', params: { followee_id: target.id }, headers: auth_headers_for(user)
        expect(response).to have_http_status(:ok)
        expect(Follow.last.followee_id).to eq(target.id)
      end
    end

    # The create action previously rendered Follow.create's return value
    # unconditionally, so a failed save (duplicate follow, or now the
    # eligibility check above) silently looked like success — the bare,
    # unsaved record's attributes rendered with a 200. Fixed as a
    # necessary corollary of enforcing eligibility at all.
    describe 'failed creation is handled explicitly, not rendered as success' do
      it 'returns 422 with a validation-error envelope for a duplicate follow, and does not create a second row' do
        create(:follow, follower: user, followee: target)

        post '/follows', params: { followee_id: target.id }, headers: auth_headers_for(user)

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body['errors']).to be_present
        expect(Follow.where(follower: user, followee: target).count).to eq(1)
      end
    end
  end

  describe 'DELETE /follows/:id' do
    let(:follower) { create(:user) }
    let(:followee) { create(:user) }
    let(:other_user) { create(:user) }
    let(:follow) { create(:follow, follower:, followee:) }

    context 'when unauthenticated' do
      it 'returns 401' do
        delete "/follows/#{follow.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated as the follower (unfollow)' do
      it 'destroys the follow' do
        delete "/follows/#{follow.id}", headers: auth_headers_for(follower)
        expect(response).to have_http_status(:no_content)
        expect(Follow.exists?(follow.id)).to be false
      end
    end

    context 'when authenticated as the followee (remove follower)' do
      it 'destroys the follow' do
        delete "/follows/#{follow.id}", headers: auth_headers_for(followee)
        expect(response).to have_http_status(:no_content)
        expect(Follow.exists?(follow.id)).to be false
      end
    end

    context 'when authenticated as an unrelated user' do
      it 'returns 403 and leaves the follow intact' do
        delete "/follows/#{follow.id}", headers: auth_headers_for(other_user)
        expect(response).to have_http_status(:forbidden)
        expect(Follow.exists?(follow.id)).to be true
      end
    end

    # ai/v1-redesign-plan.md's privacy-first-user-discovery workstream
    # (2026-11-23), Step 3 — this is purely a model-level, pre-existing
    # Follow row (created directly via FactoryBot, not through the now-
    # eligibility-gated POST /follows) whose followee doesn't pass
    # User.followable. Proves the existing destroy path is completely
    # unaffected by Step 3's new creation-time check, and no destructive
    # cleanup was performed on legacy data as part of this PR.
    it 'still allows removing a legacy follow whose followee is not (or is no longer) a public creator' do
      private_account = create(:user)
      legacy_follow = create(:follow, follower:, followee: private_account)

      delete "/follows/#{legacy_follow.id}", headers: auth_headers_for(follower)
      expect(response).to have_http_status(:no_content)
      expect(Follow.exists?(legacy_follow.id)).to be false
    end
  end

  # ai/v1-redesign-plan.md's privacy-first-user-discovery workstream
  # (2026-11-23), Step 3 — removed entirely, not gated: verified zero
  # consumers in either repo before finalizing the plan (frontend's
  # followsSlice.js never defined a getFollows-style query; this spec
  # file itself never tested a GET on either route). Matches this
  # codebase's own precedent for a deliberately-removed route (see
  # spec/requests/images_spec.rb's "legacy endpoints" tests).
  describe 'GET /follows (index) — removed' do
    it 'raises RoutingError — route removed' do
      expect { get '/follows' }.to raise_error(ActionController::RoutingError)
    end
  end

  describe 'GET /follows/:id (show) — removed' do
    it 'raises RoutingError — route removed' do
      expect { get '/follows/1' }.to raise_error(ActionController::RoutingError)
    end
  end
end

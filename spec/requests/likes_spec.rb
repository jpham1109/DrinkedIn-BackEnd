require 'rails_helper'

RSpec.describe 'Likes', type: :request do
  describe 'POST /likes' do
    let(:user) { create(:user) }
    let(:cocktail) { create(:cocktail, :published, creator_unknown: true) }

    context 'when unauthenticated' do
      it 'returns 401' do
        post '/likes', params: { liked_cocktail_id: cocktail.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      it 'creates a like as current_user' do
        post '/likes', params: { liked_cocktail_id: cocktail.id }, headers: auth_headers_for(user)
        expect(response).to have_http_status(:ok)
        expect(Like.last.liker_id).to eq(user.id)
      end

      it 'ignores a spoofed liker_id param' do
        other_user = create(:user)
        post '/likes', params: { liker_id: other_user.id, liked_cocktail_id: cocktail.id },
                       headers: auth_headers_for(user)
        expect(Like.last.liker_id).to eq(user.id)
      end
    end

    # ai/v1-redesign-plan.md's publication-lifecycle workstream
    # (2026-11-18) — a non-editor can't like, or confirm the existence
    # of, a draft by directly supplying its id. 404, never 403.
    context 'when the cocktail is a draft' do
      let(:draft) { create(:cocktail) }

      it 'returns 404 for a non-editor' do
        post '/likes', params: { liked_cocktail_id: draft.id }, headers: auth_headers_for(user)
        expect(response).to have_http_status(:not_found)
        body = JSON.parse(response.body)
        expect(body['errors'][0]['code']).to eq('not_found')
      end

      it 'allows an editor to like it' do
        post '/likes', params: { liked_cocktail_id: draft.id }, headers: auth_headers_for(create(:user, :editor))
        expect(response).to have_http_status(:ok)
        expect(Like.last.liked_cocktail_id).to eq(draft.id)
      end
    end

    it 'returns 404 for a nonexistent cocktail id' do
      post '/likes', params: { liked_cocktail_id: 0 }, headers: auth_headers_for(user)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /likes' do
    it 'excludes likes on draft cocktails for an anonymous request' do
      published = create(:cocktail, :published, creator_unknown: true)
      draft = create(:cocktail)
      create(:like, liked_cocktail: published)
      draft_like = create(:like, liked_cocktail: draft)

      get '/likes'
      ids = JSON.parse(response.body).pluck('id')
      expect(ids).not_to include(draft_like.id)
    end

    it 'includes likes on draft cocktails for an authenticated editor' do
      draft = create(:cocktail)
      draft_like = create(:like, liked_cocktail: draft)

      get '/likes', headers: auth_headers_for(create(:user, :editor))
      ids = JSON.parse(response.body).pluck('id')
      expect(ids).to include(draft_like.id)
    end

    # Direct proof that a like survives its cocktail's publish/unpublish
    # transitions — the Like row is never touched by either action, only
    # this read-time scope changes.
    it 'preserves a like across unpublish and republish, only changing visibility' do
      cocktail = create(:cocktail, :published, creator_unknown: true)
      like = create(:like, liked_cocktail: cocktail)

      cocktail.update!(published_at: nil)
      get '/likes'
      expect(JSON.parse(response.body).pluck('id')).not_to include(like.id)
      expect(Like.exists?(like.id)).to be(true)

      cocktail.update!(published_at: Time.current)
      get '/likes'
      expect(JSON.parse(response.body).pluck('id')).to include(like.id)
    end
  end

  describe 'DELETE /likes/:id' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:cocktail) { create(:cocktail) }
    let(:like) { create(:like, liker: owner, liked_cocktail: cocktail) }

    context 'when unauthenticated' do
      it 'returns 401' do
        delete "/likes/#{like.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated as the owner' do
      it 'destroys the like' do
        delete "/likes/#{like.id}", headers: auth_headers_for(owner)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when authenticated as a non-owner' do
      it 'returns 403' do
        delete "/likes/#{like.id}", headers: auth_headers_for(other_user)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end

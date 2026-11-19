require 'rails_helper'

RSpec.describe 'Users', type: :request do
  # ai/v1-redesign-plan.md's editorial-authorization workstream
  # (2026-11-18): editor must never be settable through the public
  # signup/profile-update surface — user_params doesn't permit it, so a
  # spoofed value is silently dropped, same as any other unpermitted
  # param.
  describe 'editor mass-assignment protection' do
    it 'ignores an editor param on PATCH /me' do
      user = create(:user)
      patch '/me', params: { user: { editor: true } }, headers: auth_headers_for(user)
      expect(response).to have_http_status(:ok)
      expect(user.reload.editor).to be(false)
    end

    it 'ignores an editor param on POST /signup' do
      get '/csrf_token'
      csrf_token = JSON.parse(response.body)['data']['csrf_token']

      post '/signup',
           params: { user: { username: 'newbie', password: 'password123', editor: true } },
           headers: { 'X-CSRF-Token' => csrf_token }
      expect(response).to have_http_status(:created)
      expect(User.find_by(username: 'newbie').editor).to be(false)
    end
  end

  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18) — a user's id-only nested cocktails/likes must not
  # reveal a draft cocktail's existence to a non-editor either.
  describe 'GET /users/:id draft visibility in nested associations' do
    it "excludes a draft cocktail's id from the submitter's nested cocktails for a non-editor" do
      submitter = create(:user)
      draft = create(:cocktail, submitted_by: submitter)

      get "/users/#{submitter.id}"
      ids = JSON.parse(response.body)['cocktails'].pluck('id')
      expect(ids).not_to include(draft.id)
    end

    it "includes a draft cocktail's id in the submitter's nested cocktails for an authenticated editor" do
      submitter = create(:user)
      draft = create(:cocktail, submitted_by: submitter)

      get "/users/#{submitter.id}", headers: auth_headers_for(create(:user, :editor))
      ids = JSON.parse(response.body)['cocktails'].pluck('id')
      expect(ids).to include(draft.id)
    end

    it "excludes a like on a draft cocktail from the liker's nested likes for a non-editor" do
      liker = create(:user)
      draft = create(:cocktail)
      draft_like = create(:like, liker:, liked_cocktail: draft)

      get "/users/#{liker.id}"
      ids = JSON.parse(response.body)['likes'].pluck('id')
      expect(ids).not_to include(draft_like.id)
    end

    it "includes a like on a draft cocktail in the liker's nested likes for an authenticated editor" do
      liker = create(:user)
      draft = create(:cocktail)
      draft_like = create(:like, liker:, liked_cocktail: draft)

      get "/users/#{liker.id}", headers: auth_headers_for(create(:user, :editor))
      ids = JSON.parse(response.body)['likes'].pluck('id')
      expect(ids).to include(draft_like.id)
    end
  end

  # Proves the respond_to?(:current_user) defensive guard in
  # UserSerializer doesn't raise when the serializer is manually
  # instantiated with no scope at all (SessionsController#create,
  # UsersController#signup) — it fails closed instead, treating the
  # view as non-editor regardless of the actual user's editor status.
  describe 'nested cocktails/likes on manually-scoped UserSerializer instantiations' do
    it "does not raise, and shows no drafts, in the signup response's nested cocktails" do
      editor = create(:user, :editor)
      draft = create(:cocktail, submitted_by: editor)

      get '/csrf_token'
      csrf_token = JSON.parse(response.body)['data']['csrf_token']
      post '/login', params: { session: { username: editor.username, password: 'password123' } },
                     headers: { 'X-CSRF-Token' => csrf_token }

      expect(response).to have_http_status(:ok)
      ids = JSON.parse(response.body).dig('data', 'user', 'cocktails').pluck('id')
      expect(ids).not_to include(draft.id)
    end
  end

  describe 'PATCH /me avatar upload validation' do
    let(:user) { create(:user) }

    it 'rejects a non-image content type with 422 and errors key' do
      patch '/me',
            params: { user: { avatar: invalid_type_upload } },
            headers: auth_headers_for(user)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('errors')
    end

    it 'rejects a GIF with 422' do
      patch '/me',
            params: { user: { avatar: gif_upload } },
            headers: auth_headers_for(user)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'rejects an oversized file with 422 and errors key' do
      patch '/me',
            params: { user: { avatar: oversized_upload } },
            headers: auth_headers_for(user)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key('errors')
    end

    it 'accepts a valid image and returns 200' do
      patch '/me',
            params: { user: { avatar: valid_image_upload } },
            headers: auth_headers_for(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /me background variant processing' do
    let(:user) { create(:user) }

    it 'enqueues ProcessImageVariantJob when a valid avatar is uploaded' do
      expect do
        patch '/me',
              params: { user: { avatar: valid_image_upload } },
              headers: auth_headers_for(user)
      end.to have_enqueued_job(ProcessImageVariantJob)
    end

    it 'does not enqueue ProcessImageVariantJob when no avatar is uploaded' do
      expect do
        patch '/me',
              params: { user: { full_name: 'New Name' } },
              headers: auth_headers_for(user)
      end.not_to have_enqueued_job(ProcessImageVariantJob)
    end

    it 'does not enqueue ProcessImageVariantJob when an invalid avatar is rejected' do
      expect do
        patch '/me',
              params: { user: { avatar: invalid_type_upload } },
              headers: auth_headers_for(user)
      end.not_to have_enqueued_job(ProcessImageVariantJob)
    end
  end
end

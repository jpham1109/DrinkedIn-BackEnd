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
           params: { user: { username: 'newbie', password: 'password123', email: 'newbie@example.com', editor: true } },
           headers: { 'X-CSRF-Token' => csrf_token }
      expect(response).to have_http_status(:created)
      expect(User.find_by(username: 'newbie').editor).to be(false)
    end
  end

  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18) — a user's id-only nested cocktails/likes must not
  # reveal a draft cocktail's existence to a non-editor either.
  #
  # Authenticated as the submitter/liker themselves, not anonymously —
  # ai/v1-redesign-plan.md's privacy-first-user-discovery workstream
  # (2026-11-23), Step 3 restricts GET /users/:id to self-or-editor, so
  # an anonymous request to this endpoint no longer returns a body at
  # all (404). UserSerializer#cocktails/#likes conceal drafts from
  # anyone who isn't an *editor*, independent of self-ownership — a
  # user views their own drafts exactly as concealed as anyone else
  # would, which is what these examples are actually proving.
  describe 'GET /users/:id draft visibility in nested associations' do
    it "excludes a draft cocktail's id from the submitter's own nested cocktails, viewed as a non-editor self" do
      submitter = create(:user)
      draft = create(:cocktail, submitted_by: submitter)

      get "/users/#{submitter.id}", headers: auth_headers_for(submitter)
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

    it "excludes a like on a draft cocktail from the liker's own nested likes, viewed as a non-editor self" do
      liker = create(:user)
      draft = create(:cocktail)
      draft_like = create(:like, liker:, liked_cocktail: draft)

      get "/users/#{liker.id}", headers: auth_headers_for(liker)
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

  # ai/v1-redesign-plan.md's privacy-first-user-discovery workstream
  # (2026-11-23), Step 3 — registered accounts are private by default:
  # GET /users is editor-only, GET /users/:id is self-or-editor only.
  describe 'GET /users authorization' do
    it 'returns 401 for an anonymous request (require_editor’s own existing require_login fallback)' do
      get '/users'
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['errors'][0]['code']).to eq('authentication_required')
    end

    it 'returns 403 for an authenticated non-editor' do
      get '/users', headers: auth_headers_for(create(:user))
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns 200 for an authenticated editor' do
      get '/users', headers: auth_headers_for(create(:user, :editor))
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /users/:id authorization' do
    it 'returns 404 for an anonymous request — concealment, matching the draft-concealment convention' do
      other = create(:user)
      get "/users/#{other.id}"
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for a nonexistent id' do
      get '/users/999999', headers: auth_headers_for(create(:user))
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for an authenticated non-owner, non-editor — identical to a nonexistent id' do
      other = create(:user)
      get "/users/#{other.id}", headers: auth_headers_for(create(:user))
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 200 for the account owner viewing their own profile' do
      user = create(:user)
      get "/users/#{user.id}", headers: auth_headers_for(user)
      expect(response).to have_http_status(:ok)
    end

    it 'returns 200 for an authenticated editor viewing any account' do
      other = create(:user)
      get "/users/#{other.id}", headers: auth_headers_for(create(:user, :editor))
      expect(response).to have_http_status(:ok)
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

  # ai/v1-redesign-plan.md's users.email workstream (2026-11-19),
  # updated by the email-signup-completion workstream (2026-11-22):
  # email is now required for new signups (validates :email,
  # presence: true, on: :create, app/models/user.rb).
  describe 'email' do
    it 'accepts a valid email on POST /signup and stores it' do
      get '/csrf_token'
      csrf_token = JSON.parse(response.body)['data']['csrf_token']

      post '/signup',
           params: { user: { username: 'has-an-email', password: 'password123', email: 'person@example.com' } },
           headers: { 'X-CSRF-Token' => csrf_token }
      expect(response).to have_http_status(:created)
      expect(User.find_by(username: 'has-an-email').email).to eq('person@example.com')
    end

    it 'returns 422 with a validation-error envelope for a missing email on signup' do
      get '/csrf_token'
      csrf_token = JSON.parse(response.body)['data']['csrf_token']

      post '/signup',
           params: { user: { username: 'no-email-signup', password: 'password123' } },
           headers: { 'X-CSRF-Token' => csrf_token }

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      email_error = body['errors'].find { |e| e['field'] == 'email' }
      expect(email_error).to be_present
      expect(email_error['code']).to eq('validation_failed')
      expect(email_error['message']).to be_present
      expect(User.find_by(username: 'no-email-signup')).to be_nil
    end

    # Model-level format/uniqueness coverage already exists
    # (spec/models/user_spec.rb) — these two prove the same validations
    # actually surface correctly through the signup API boundary, with
    # the standard validation-error envelope (ApiResponses#render_validation_errors).
    it 'returns 422 with a validation-error envelope for a malformed email on signup' do
      get '/csrf_token'
      csrf_token = JSON.parse(response.body)['data']['csrf_token']

      post '/signup',
           params: { user: { username: 'bad-email-signup', password: 'password123', email: 'not-an-email' } },
           headers: { 'X-CSRF-Token' => csrf_token }

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      email_error = body['errors'].find { |e| e['field'] == 'email' }
      expect(email_error).to be_present
      expect(email_error['code']).to eq('validation_failed')
      expect(email_error['message']).to be_present
      expect(User.find_by(username: 'bad-email-signup')).to be_nil
    end

    it 'returns 422 with a validation-error envelope for a duplicate email on signup' do
      create(:user, email: 'person@example.com')

      get '/csrf_token'
      csrf_token = JSON.parse(response.body)['data']['csrf_token']

      post '/signup',
           params: { user: { username: 'dup-email-signup', password: 'password123', email: 'Person@Example.com' } },
           headers: { 'X-CSRF-Token' => csrf_token }

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      email_error = body['errors'].find { |e| e['field'] == 'email' }
      expect(email_error).to be_present
      expect(email_error['code']).to eq('validation_failed')
      expect(email_error['message']).to be_present
      expect(User.find_by(username: 'dup-email-signup')).to be_nil
    end

    it 'ignores an email param on PATCH /me — not yet acceptable through this path' do
      user = create(:user, email: 'original@example.com')
      patch '/me', params: { user: { email: 'changed@example.com' } }, headers: auth_headers_for(user)
      expect(response).to have_http_status(:ok)
      expect(user.reload.email).to eq('original@example.com')
    end

    # Public means public, no exceptions — not for the owner viewing
    # their own listed profile, not for an editor viewing anyone's.
    #
    # The "anonymously"/"someone else's account" variants of these two
    # examples were retired here: GET /users and GET /users/:id no
    # longer return a body to inspect for those auth states at all
    # (Step 3 restricts both to editor-only / self-or-editor-only — see
    # the dedicated authorization describe blocks above) — asserting
    # "no email key" on a 401/403/404 response would be vacuously true
    # and wouldn't actually be testing this guarantee anymore.
    describe 'never exposed through public user endpoints' do
      it "excludes email from GET /users/:id on the viewer's own account" do
        user = create(:user, email: 'person@example.com')
        get "/users/#{user.id}", headers: auth_headers_for(user)
        expect(JSON.parse(response.body)).not_to have_key('email')
      end

      it 'excludes email from GET /users/:id even for an authenticated editor' do
        other = create(:user, email: 'person@example.com')
        get "/users/#{other.id}", headers: auth_headers_for(create(:user, :editor))
        expect(JSON.parse(response.body)).not_to have_key('email')
      end

      it 'excludes email from GET /users (index) for an authenticated editor too' do
        create(:user, email: 'person@example.com')
        get '/users', headers: auth_headers_for(create(:user, :editor))
        data = JSON.parse(response.body)
        expect(data).to all(satisfy { |entry| !entry.key?('email') })
      end
    end

    describe 'included in private, self-only responses' do
      it 'includes email on GET /me' do
        user = create(:user, email: 'person@example.com')
        get '/me', headers: auth_headers_for(user)
        expect(JSON.parse(response.body)['data']['email']).to eq('person@example.com')
      end

      it "includes the (unchanged) email on PATCH /me's own response" do
        user = create(:user, email: 'person@example.com')
        patch '/me', params: { user: { full_name: 'New Name' } }, headers: auth_headers_for(user)
        expect(JSON.parse(response.body)['email']).to eq('person@example.com')
      end

      it 'includes email in the POST /signup response' do
        get '/csrf_token'
        csrf_token = JSON.parse(response.body)['data']['csrf_token']

        post '/signup',
             params: { user: { username: 'signup-email-check', password: 'password123',
                                email: 'person@example.com' } },
             headers: { 'X-CSRF-Token' => csrf_token }
        expect(JSON.parse(response.body).dig('data', 'user', 'email')).to eq('person@example.com')
      end

      it 'includes email in the POST /login response' do
        user = create(:user, email: 'person@example.com')
        get '/csrf_token'
        csrf_token = JSON.parse(response.body)['data']['csrf_token']

        post '/login', params: { session: { username: user.username, password: 'password123' } },
                       headers: { 'X-CSRF-Token' => csrf_token }
        expect(JSON.parse(response.body).dig('data', 'user', 'email')).to eq('person@example.com')
      end
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

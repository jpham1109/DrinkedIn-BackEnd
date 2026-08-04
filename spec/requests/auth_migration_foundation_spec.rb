require 'rails_helper'

# Covers PR 1 of ai/auth-migration-plan.md: session/cookie/CSRF middleware,
# the AuthenticatesRequest concern's dual-mode resolution and precedence,
# the CSRF exemption's success-based (not header-presence-based) design,
# and the GET /csrf_token endpoint. Uses GET /me (SessionsController#show,
# unmodified in this PR) to observe current_user resolution, and
# PATCH /cocktails/:id (already login+ownership-protected) as an existing
# mutating endpoint to observe CSRF enforcement — neither SessionsController
# nor CocktailsController is changed by this PR.
RSpec.describe 'Auth migration — PR 1 backend foundation', type: :request do
  let(:user) { create(:user) }

  describe 'session-based resolution' do
    it 'resolves current_user via a session established outside any bearer token' do
      log_in_via_session(user)

      get '/me'

      expect(response).to have_http_status(:accepted)
      expect(JSON.parse(response.body)['id']).to eq(user.id)
    end

    it 'falls through to bearer resolution when the session references a deleted user' do
      other_user = create(:user)
      log_in_via_session(user)
      user.destroy

      get '/me', headers: auth_headers_for(other_user)

      expect(response).to have_http_status(:accepted)
      expect(JSON.parse(response.body)['id']).to eq(other_user.id)
    end
  end

  describe 'bearer resolution (unchanged regression coverage)' do
    it 'resolves current_user via a valid bearer token' do
      get '/me', headers: auth_headers_for(user)

      expect(response).to have_http_status(:accepted)
      expect(JSON.parse(response.body)['id']).to eq(user.id)
    end

    it 'returns unauthorized for a request with no Authorization header at all' do
      get '/me'

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized for a malformed bearer token' do
      get '/me', headers: { 'Authorization' => 'Bearer not-a-real-token' }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized when the bearer token references a deleted user' do
      headers = auth_headers_for(user)
      user.destroy

      get('/me', headers:)

      expect(response).to have_http_status(:unauthorized)
    end

    it 'rejects an expired bearer token, independent of whether issue_token issues one yet' do
      headers = bearer_headers_for_payload({ user_id: user.id, exp: 1.hour.ago.to_i })

      get('/me', headers:)

      expect(response).to have_http_status(:unauthorized)
    end

    it 'accepts a legacy-shaped bearer token with no exp claim at all' do
      headers = bearer_headers_for_payload({ user_id: user.id })

      get('/me', headers:)

      expect(response).to have_http_status(:accepted)
      expect(JSON.parse(response.body)['id']).to eq(user.id)
    end
  end

  describe 'session precedence' do
    it 'resolves to the session user, not a different bearer-token user, when both are present' do
      user_b = create(:user)
      log_in_via_session(user)

      get '/me', headers: auth_headers_for(user_b)

      expect(JSON.parse(response.body)['id']).to eq(user.id)
    end
  end

  describe 'GET /csrf_token' do
    it 'returns a token in the standard envelope for a request with no prior session' do
      get '/csrf_token'

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['data']['csrf_token']).to be_present
    end
  end

  describe 'CSRF enforcement on cookie/session-authenticated mutations' do
    let(:owner) { create(:user) }
    let(:cocktail) { create(:cocktail, bartender: owner) }

    it 'rejects a session-authenticated mutation with no CSRF token, with csrf_invalid' do
      log_in_via_session(owner)

      patch "/cocktails/#{cocktail.id}", params: { cocktail: { name: 'Updated' } }

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body['errors'][0]['code']).to eq('csrf_invalid')
    end

    it 'rejects a session-authenticated mutation with an invalid CSRF token, with csrf_invalid' do
      log_in_via_session(owner)

      patch "/cocktails/#{cocktail.id}",
            params: { cocktail: { name: 'Updated' } },
            headers: { 'X-CSRF-Token' => 'not-a-real-token' }

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body['errors'][0]['code']).to eq('csrf_invalid')
    end

    it 'accepts a session-authenticated mutation with a valid CSRF token' do
      log_in_via_session(owner)
      get '/csrf_token'
      csrf_token = JSON.parse(response.body)['data']['csrf_token']

      patch "/cocktails/#{cocktail.id}",
            params: { cocktail: { name: 'Updated' } },
            headers: { 'X-CSRF-Token' => csrf_token }

      expect(response).to have_http_status(:ok)
    end

    it 'does not require a CSRF token for a bearer-authenticated mutation (exemption)' do
      patch "/cocktails/#{cocktail.id}",
            params: { cocktail: { name: 'Updated' } },
            headers: auth_headers_for(owner)

      expect(response).to have_http_status(:ok)
    end

    it 'does not let a bogus Authorization header bypass CSRF on a session-authenticated request' do
      log_in_via_session(owner)

      patch "/cocktails/#{cocktail.id}",
            params: { cocktail: { name: 'Updated' } },
            headers: { 'Authorization' => 'Bearer not-a-real-token' }

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body['errors'][0]['code']).to eq('csrf_invalid')
    end

    it 'does not require a CSRF token for a safe GET request' do
      get '/cocktails'

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'credentialed CORS' do
    it 'reflects Access-Control-Allow-Origin and Allow-Credentials for the configured origin' do
      get '/cocktails', headers: { 'Origin' => ENV.fetch('CLIENT_URL', nil) }

      expect(response.headers['Access-Control-Allow-Origin']).to eq(ENV.fetch('CLIENT_URL', nil))
      expect(response.headers['Access-Control-Allow-Credentials']).to eq('true')
    end

    it 'omits permissive CORS headers for an unconfigured origin' do
      get '/cocktails', headers: { 'Origin' => 'http://evil.example.com' }

      expect(response).to have_http_status(:ok)
      expect(response.headers['Access-Control-Allow-Origin']).to be_nil
    end
  end
end

require 'rails_helper'

# Covers PR 2 of ai/auth-migration-plan.md: SessionsController#create and
# UsersController#signup establish real sessions (reset_session +
# session[:user_id]), both now CSRF-protected — PR 1's temporary
# skip_forgery_protection is removed in this PR, shipped in the same
# deploy as the frontend's CSRF/credentials transport (no safe
# intermediate state between the two, see "Sequencing correction").
# SessionsController#show (/me) and a new logout action adopt the Phase 1
# envelope; issue_token gains a 24h exp claim (decision #23).
#
# Supersedes the deleted auth_migration_login_signup_regression_spec.rb —
# its entire premise (login/signup succeed *without* a CSRF token) is
# exactly what this PR intentionally reverses.
RSpec.describe 'Auth migration — PR 2 session cutover', type: :request do
  let(:user) { create(:user, password: 'password123') }

  describe 'POST /login' do
    it 'establishes a real session, not just a JWT — verified via a follow-up session-only request' do
      csrf_token = fetch_csrf_token

      post '/login',
           params: { session: { username: user.username, password: 'password123' } },
           headers: { 'X-CSRF-Token' => csrf_token }
      expect(response).to have_http_status(:ok)

      get '/me'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig('data', 'id')).to eq(user.id)
    end

    it 'issues a new session cookie value on login (session fixation protection)' do
      csrf_token = fetch_csrf_token
      pre_login_cookie = response.cookies['_drinkedin_session']
      # Asserted before the comparison below — otherwise a blank
      # pre_login_cookie would make "not_to eq" trivially true without
      # actually proving rotation of a real, pre-existing cookie.
      expect(pre_login_cookie).to be_present

      post '/login',
           params: { session: { username: user.username, password: 'password123' } },
           headers: { 'X-CSRF-Token' => csrf_token }

      post_login_cookie = response.cookies['_drinkedin_session']
      expect(post_login_cookie).to be_present
      expect(post_login_cookie).not_to eq(pre_login_cookie)
    end

    it 'returns the full nested envelope shape, with no jwt field (removed in PR 5)' do
      csrf_token = fetch_csrf_token

      post '/login',
           params: { session: { username: user.username, password: 'password123' } },
           headers: { 'X-CSRF-Token' => csrf_token }

      body = JSON.parse(response.body)
      expect(body.dig('data', 'user', 'id')).to eq(user.id)
      expect(body.dig('data', 'user', 'username')).to eq(user.username)
      # Explicit negative check, not just absence-by-omission — proves the
      # field was actually removed rather than just never asserted on.
      expect(body['data']).not_to have_key('jwt')
    end

    it 'returns 200, not the inherited 202' do
      csrf_token = fetch_csrf_token

      post '/login',
           params: { session: { username: user.username, password: 'password123' } },
           headers: { 'X-CSRF-Token' => csrf_token }

      expect(response).to have_http_status(:ok)
    end

    it 'returns an identical error body — code and message — for an unknown username and a wrong password' do
      csrf_token = fetch_csrf_token
      post '/login',
           params: { session: { username: 'no-such-user', password: 'whatever' } },
           headers: { 'X-CSRF-Token' => csrf_token }
      expect(response).to have_http_status(:unauthorized)
      unknown_user_errors = JSON.parse(response.body)['errors']

      csrf_token = fetch_csrf_token
      post '/login',
           params: { session: { username: user.username, password: 'wrong-password' } },
           headers: { 'X-CSRF-Token' => csrf_token }
      expect(response).to have_http_status(:unauthorized)
      wrong_password_errors = JSON.parse(response.body)['errors']

      # Full error object comparison, not just the code — a matching code
      # with a differing message would still leak which case occurred.
      expect(unknown_user_errors).to eq(wrong_password_errors)
      expect(unknown_user_errors[0]['code']).to eq('authentication_required')
    end

    it 'does not establish a session on failed login' do
      csrf_token = fetch_csrf_token
      post '/login',
           params: { session: { username: user.username, password: 'wrong-password' } },
           headers: { 'X-CSRF-Token' => csrf_token }

      get '/me'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'requires a valid CSRF token — fails with csrf_invalid when none is sent (the reversal of PR 1)' do
      post '/login', params: { session: { username: user.username, password: 'password123' } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors'][0]['code']).to eq('csrf_invalid')
    end

    it 'invalidates the CSRF token that was used to log in, once login resets the session — ' \
       'a second login attempt reusing it fails, a freshly fetched one succeeds' do
      csrf_token = fetch_csrf_token
      post '/login',
           params: { session: { username: user.username, password: 'password123' } },
           headers: { 'X-CSRF-Token' => csrf_token }
      expect(response).to have_http_status(:ok)

      # Reusing the pre-login token after reset_session rotated the
      # session's CSRF secret — must now fail, proving rotation actually
      # invalidates it rather than merely coexisting with a new one.
      post '/login',
           params: { session: { username: user.username, password: 'password123' } },
           headers: { 'X-CSRF-Token' => csrf_token }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors'][0]['code']).to eq('csrf_invalid')

      # A token fetched fresh, against the post-login session, succeeds.
      fresh_csrf_token = fetch_csrf_token
      post '/login',
           params: { session: { username: user.username, password: 'password123' } },
           headers: { 'X-CSRF-Token' => fresh_csrf_token }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /signup' do
    let(:signup_params) { { user: { username: 'brandnewuser', full_name: 'New User', password: 'password123' } } }

    it 'establishes a real session and returns 201 with the full envelope shape, with no jwt field (removed in PR 5)' do
      csrf_token = fetch_csrf_token
      post '/signup', params: signup_params, headers: { 'X-CSRF-Token' => csrf_token }

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body.dig('data', 'user', 'username')).to eq('brandnewuser')
      # Explicit negative check, not just absence-by-omission — proves the
      # field was actually removed rather than just never asserted on.
      expect(body['data']).not_to have_key('jwt')

      get '/me'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig('data', 'username')).to eq('brandnewuser')
    end

    it 'requires a valid CSRF token — fails with csrf_invalid when none is sent (the reversal of PR 1)' do
      post '/signup', params: signup_params

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors'][0]['code']).to eq('csrf_invalid')
    end

    it 'invalidates the CSRF token that was used to sign up, once signup resets the session — ' \
       'reusing it on a second request fails with csrf_invalid before any signup logic runs' do
      csrf_token = fetch_csrf_token
      post '/signup', params: signup_params, headers: { 'X-CSRF-Token' => csrf_token }
      expect(response).to have_http_status(:created)

      # protect_from_forgery runs as a before_action ahead of the
      # controller's own logic, so this still surfaces csrf_invalid (not a
      # username-uniqueness validation error) even though 'brandnewuser'
      # is now taken — proving the token itself is what's rejected here,
      # not incidentally shadowed by an unrelated failure.
      post '/signup', params: signup_params, headers: { 'X-CSRF-Token' => csrf_token }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors'][0]['code']).to eq('csrf_invalid')

      fresh_csrf_token = fetch_csrf_token
      post '/signup',
           params: { user: { username: 'anotherbrandnewuser', full_name: 'New User', password: 'password123' } },
           headers: { 'X-CSRF-Token' => fresh_csrf_token }
      expect(response).to have_http_status(:created)
    end

    it 'creates a Workplace when work_at is present on a successful signup' do
      csrf_token = fetch_csrf_token
      post '/signup', params: signup_params.merge(work_at: 'The Alibi Room'), headers: { 'X-CSRF-Token' => csrf_token }

      expect(response).to have_http_status(:created)
      user_id = JSON.parse(response.body).dig('data', 'user', 'id')
      expect(Workplace.where(bartender_id: user_id).count).to eq(1)
      expect(Bar.find_by(name: 'The Alibi Room')).to be_present
    end

    it 'does not create an orphaned Bar when signup fails with work_at present (the bug found in review)' do
      create(:user, username: 'taken')
      csrf_token = fetch_csrf_token

      post '/signup',
           params: { user: { username: 'taken', full_name: 'Dup', password: 'password123' }, work_at: 'Orphan Bar' },
           headers: { 'X-CSRF-Token' => csrf_token }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(Bar.find_by(name: 'Orphan Bar')).to be_nil
    end
  end

  describe 'DELETE /logout' do
    it 'clears the session' do
      log_in_via_session(user)
      csrf_token = fetch_csrf_token

      delete '/logout', headers: { 'X-CSRF-Token' => csrf_token }
      expect(response).to have_http_status(:no_content)

      get '/me'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'requires a valid CSRF token from an authenticated session — csrf_invalid, not 401' do
      log_in_via_session(user)

      delete '/logout'

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors'][0]['code']).to eq('csrf_invalid')
    end

    it 'succeeds with no prior session, given a valid CSRF token (idempotent w.r.t. auth state)' do
      csrf_token = fetch_csrf_token

      delete '/logout', headers: { 'X-CSRF-Token' => csrf_token }

      expect(response).to have_http_status(:no_content)
    end

    it 'returns authentication_required, not csrf_invalid, for a fully anonymous request with no CSRF token at all' do
      delete '/logout'

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['errors'][0]['code']).to eq('authentication_required')
    end
  end

  describe 'GET /me' do
    it 'succeeds via session only, no bearer header' do
      log_in_via_session(user)

      get '/me'

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig('data', 'id')).to eq(user.id)
    end

    it 'returns 401 when logged out' do
      get '/me'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  # issue_token has had no HTTP caller since PR 5 removed the temporary
  # jwt response field from SessionsController#create/UsersController#signup
  # — it's kept only as reserved mobile-auth infrastructure
  # (ai/auth-migration-plan.md PR 5). These exercise the real production
  # method directly (issue_token_for, spec/support/auth_helpers.rb) rather
  # than via an HTTP login response, which no longer carries a token. No
  # login/logout round trip is needed to isolate the bearer path either —
  # these examples never call /login, so there's no session for
  # current_user to resolve first, and resolution falls straight to bearer.
  describe 'issue_token exp claim (decision #23)' do
    it 'sets exp to approximately 24 hours from issuance' do
      jwt = issue_token_for(user)
      payload, = JWT.decode(jwt, Rails.application.credentials.jwt_key, true, { algorithm: 'HS256' })

      expect(payload['exp']).to be_within(5).of(24.hours.from_now.to_i)
    end

    it 'still accepts the token via bearer auth shortly before it expires' do
      jwt = issue_token_for(user)

      travel_to 23.hours.from_now do
        get '/me', headers: { 'Authorization' => "Bearer #{jwt}" }
        expect(response).to have_http_status(:ok)
      end
    end

    it 'rejects the token via bearer auth once 25 hours have actually elapsed, not just by claim value' do
      jwt = issue_token_for(user)

      travel_to 25.hours.from_now do
        get '/me', headers: { 'Authorization' => "Bearer #{jwt}" }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

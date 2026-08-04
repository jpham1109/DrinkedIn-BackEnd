require 'rails_helper'

# PR 1 (ai/auth-migration-plan.md) promised login/signup keep working
# unchanged for the current bearer-JWT frontend, which sends neither a
# bearer token (it doesn't have one yet) nor a CSRF token (that's PR 3/4
# work) on these two requests. This file exists because that promise was
# not actually covered by auth_migration_foundation_spec.rb — flagged
# during review — and a passing suite that never exercises these two
# endpoints without a CSRF token doesn't prove the promise held.
RSpec.describe 'Auth migration — PR 1 login/signup regression', type: :request do
  describe 'POST /login' do
    let!(:user) { create(:user, password: 'password123') }

    it 'succeeds with no CSRF token and no Authorization header, exactly as before this PR' do
      post '/login', params: { session: { username: user.username, password: 'password123' } }

      expect(response).to have_http_status(:accepted)
      body = JSON.parse(response.body)
      expect(body['jwt']).to be_present
      expect(body['user']).to be_present
    end
  end

  describe 'POST /signup' do
    it 'succeeds with no CSRF token and no Authorization header, exactly as before this PR' do
      post '/signup', params: { user: { username: 'brandnewuser', full_name: 'New User', password: 'password123' } }

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body['jwt']).to be_present
      expect(body['user']).to be_present
    end
  end
end

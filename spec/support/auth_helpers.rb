module AuthHelpers
  def auth_headers_for(user)
    token = JWT.encode({ user_id: user.id }, Rails.application.credentials.jwt_key, 'HS256')
    { 'Authorization' => "Bearer #{token}" }
  end

  # Manually constructs a bearer JWT with an arbitrary payload, bypassing
  # issue_token — for specs exercising the decode/verify path directly
  # (expired tokens, legacy tokens with no exp claim) independent of
  # whether issue_token produces such tokens yet. See
  # ai/auth-migration-plan.md's JWT decoder audit and decision #23.
  def bearer_headers_for_payload(payload)
    token = JWT.encode(payload, Rails.application.credentials.jwt_key, 'HS256')
    { 'Authorization' => "Bearer #{token}" }
  end

  # Establishes a real, correctly-signed session cookie via the test-only
  # TestSupport::SessionsController route (see config/routes.rb and
  # ai/auth-migration-plan.md PR 1) so the integration session's cookie jar
  # carries it into subsequent requests within the same example. Request
  # specs cannot pre-populate `session` directly — Rails 7.0.8's `session`
  # reader only reflects the last processed request, verified against this
  # app's exact installed Rails version rather than assumed.
  def log_in_via_session(user)
    post '/test_support/session', params: { user_id: user.id }
    raise "log_in_via_session failed: #{response.status}" unless response.status == 204
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end

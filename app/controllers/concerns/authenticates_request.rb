# frozen_string_literal: true

# Centralizes identity resolution per ai/auth-design.md's dual-client model.
#
# Resolution order: session (web) first, then bearer JWT (reserved for the
# future mobile client) — see ai/auth-migration-plan.md "Session precedence"
# for the exact fallback rules this implements.
module AuthenticatesRequest
  extend ActiveSupport::Concern

  # Memoized so repeated calls within a request don't re-run resolution.
  # Session is tried first; bearer is only consulted if no session resolved
  # to a real user (including a session that references a deleted user).
  def current_user
    return @current_user if defined?(@current_user)

    @current_user = resolve_session_user || resolve_bearer_user
  end

  # True only when current_user was actually resolved via a successfully
  # verified bearer token — not merely when an Authorization header is
  # present. Used to exempt genuine bearer-authenticated requests from CSRF
  # checks (see ai/auth-migration-plan.md "CSRF strategy"). Because bearer
  # resolution never runs once a session has already resolved, a bogus
  # Authorization header alongside a valid session cannot make this true.
  def current_user_via_bearer?
    current_user.present? && @auth_source == :bearer
  end

  def logged_in?
    !!current_user
  end

  def require_login
    return if logged_in?

    render_error(
      code: 'authentication_required',
      message: 'You must be logged in to perform this action.',
      status: :unauthorized
    )
  end

  # secret key saved away in a credentials file
  def jwt_key
    Rails.application.credentials.jwt_key
  end

  # method to encode a token for a user when they login or signup
  # exp claim: decision #23 — 24h transitional window, revisit alongside
  # real refresh-token rotation once bearer auth is mobile-only.
  def issue_token(user)
    JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, jwt_key, 'HS256')
  end

  private

  def resolve_session_user
    user = User.find_by(id: session[:user_id])
    @auth_source = :session if user
    user
  end

  def resolve_bearer_user
    user_id = decoded_token.first['user_id']
    user = User.find_by(id: user_id)
    @auth_source = :bearer if user
    user
  end

  # method to decode a token given to us by the client
  def decoded_token
    JWT.decode(token, jwt_key, true, { algorithm: 'HS256' })
  rescue JWT::DecodeError
    [{ error: 'Invalid Token' }]
  end

  # method to get the token from the client
  def token
    request.headers['Authorization']&.split(' ')&.last
  end
end

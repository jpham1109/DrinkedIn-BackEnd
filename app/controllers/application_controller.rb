# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection
  include ApiResponses
  include AuthenticatesRequest

  # Session-authenticated (cookie/CSRF-driven) requests are protected;
  # genuinely bearer-authenticated requests are exempt, since a bearer
  # token isn't an ambient credential a forged cross-site request could
  # attach on its own. See ai/auth-migration-plan.md "CSRF strategy" for
  # the full rationale, including why this checks successful bearer
  # resolution rather than mere Authorization-header presence.
  protect_from_forgery with: :exception, unless: -> { current_user_via_bearer? }

  # A request with no credential at all (no session, no bearer) still hits
  # this before current_user-gated before_actions like require_login run —
  # protect_from_forgery is declared here in ApplicationController, ahead
  # of any subclass's require_login. Without this branch, a fully
  # unauthenticated request to an already-require_login-gated endpoint
  # would surface csrf_invalid (422) instead of the existing, tested
  # authentication_required (401) contract (decision #10) — the request is
  # blocked either way, this only picks which error is more informative.
  # A session-authenticated request with a missing/invalid token (current_user
  # present, just not via bearer) still correctly gets csrf_invalid.
  #
  # Login/signup override prefer_authentication_error_over_csrf? to always
  # return false (see SessionsController#create, UsersController#signup) —
  # "you must be logged in" is a nonsensical message for the request that
  # IS the attempt to log in, and current_user is *always* blank there by
  # definition, so the default rule would mask every CSRF failure on those
  # two actions as authentication_required instead. Every other action
  # (including logout, which is otherwise unauthenticated-callable) keeps
  # the default priority.
  rescue_from ActionController::InvalidAuthenticityToken do
    if prefer_authentication_error_over_csrf?
      render_error(
        code: 'authentication_required',
        message: 'You must be logged in to perform this action.',
        status: :unauthorized
      )
    else
      render_error(
        code: 'csrf_invalid',
        message: 'Invalid or missing CSRF token.',
        status: :unprocessable_entity
      )
    end
  end

  private

  def prefer_authentication_error_over_csrf?
    current_user.blank?
  end
end

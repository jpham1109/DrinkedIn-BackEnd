# frozen_string_literal: true

# Test-only helper: establishes session[:user_id] via a real request through
# the actual session middleware, producing a correctly-signed session cookie
# that Rails request specs can carry into a subsequent request. Rails 7.0.8's
# integration test `session` reader only reflects the *last processed*
# request (ActionDispatch::TestProcess#session => @request.session) — it
# cannot be pre-populated before the first request, so this route exists
# instead of assuming direct session mutation works in request specs. Not
# routed outside Rails.env.test? (see config/routes.rb). Deliberately skips
# CSRF — it's test setup scaffolding, not a path whose CSRF behavior needs
# verification (the real login/logout endpoints cover that once they exist).
module TestSupport
  class SessionsController < ApplicationController
    skip_forgery_protection

    def create
      session[:user_id] = params.require(:user_id)
      head :no_content
    end
  end
end

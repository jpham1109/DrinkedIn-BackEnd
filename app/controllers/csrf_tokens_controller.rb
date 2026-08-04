# frozen_string_literal: true

# Issues the CSRF token the frontend attaches as X-CSRF-Token on
# cookie-authenticated mutating requests. Safe GET, not itself
# CSRF-protected, not behind require_login — an anonymous visitor needs a
# token before login/signup can be protected too. See
# ai/auth-migration-plan.md "CSRF token lifecycle".
class CsrfTokensController < ApplicationController
  def show
    render_success({ csrf_token: form_authenticity_token })
  end
end

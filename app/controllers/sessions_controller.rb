# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :require_login, only: :show

  def show
    render_success(current_user)
  end

  # PR 1's skip_forgery_protection only: :create is removed here (PR 2) —
  # login now establishes a session, so it must be CSRF-protected like any
  # other cookie-authenticated mutation. This ships in the same deploy as
  # the frontend's CSRF/credentials transport (ai/auth-migration-plan.md
  # PR 2, "Sequencing correction") — there is no safe intermediate state
  # between the two.
  def create
    user = User.find_by(username: session_params[:username])
    if user&.authenticate(session_params[:password])
      reset_session
      session[:user_id] = user.id
      token = issue_token(user)
      render_success({ user: UserSerializer.new(user), jwt: token }, status: :ok)
    else
      # Unknown username and wrong password return the same error —
      # deliberately not distinguished, to avoid formalizing username
      # enumeration into the API contract (ai/auth-migration-plan.md PR 2).
      render_error(
        code: 'authentication_required',
        message: 'Invalid username or password',
        status: :unauthorized
      )
    end
  end

  # Idempotent with respect to login state — safe to call whether or not
  # a session currently exists, since reset_session just clears/rotates
  # either way. Deliberately NOT exempt from CSRF: unlike create/signup,
  # nothing calls this endpoint yet, so there's no existing-frontend
  # compatibility constraint that would justify skipping the check.
  def destroy
    reset_session
    head :no_content
  end

  private

  def session_params
    params.require(:session).permit(:username, :password)
  end

  # current_user is always blank on a login attempt by definition — the
  # default authentication_required-takes-priority rule (ApplicationController)
  # would mask every CSRF failure here as "you must be logged in," which
  # makes no sense for the request that IS the attempt to log in. Always
  # surface the real problem instead.
  def prefer_authentication_error_over_csrf?
    return false if action_name == 'create'

    super
  end
end

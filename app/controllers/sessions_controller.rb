# frozen_string_literal: true

class SessionsController < ApplicationController
  # Login necessarily happens before any session exists, so current_user
  # is always blank here and CSRF can't yet be satisfied by a token this
  # not-yet-authenticated request has no way to have fetched under the
  # current (pre-PR-3/4) frontend. Skipped here, narrowly, so PR 1 keeps
  # its own promise that the existing bearer-JWT login flow keeps working
  # unchanged. Real login-CSRF protection is deferred, not abandoned — see
  # ai/auth-migration-plan.md PR 1's "Known gap" note for when this comes
  # back.
  skip_forgery_protection only: :create

  def create
    user = User.find_by(username: session_params[:username])
    if user&.authenticate(session_params[:password])
      token = issue_token(user)
      render json: { user: UserSerializer.new(user), jwt: token }, status: :accepted
    elsif !user
      render json: { error: 'No such username exists yet.' }, status: :not_found
    else
      render json: { error: 'Invalid username or password' }, status: :unauthorized
    end
  end

  def show
    if logged_in?
      render json: current_user, status: :accepted
    else
      render json: { error: 'User is not logged in/could not be found.' }, status: :unauthorized
    end
  end

  private

  def session_params
    params.require(:session).permit(:username, :password)
  end
end

class SessionsController < ApplicationController
  def create
    user = User.find_by(username: session_params[:username])
    if user && user.authenticate(session_params[:password])
      token = issue_token(user)
      render json: { user: UserSerializer.new(user), jwt: token }, status: :accepted
    elsif !user
      render json: { error: "No such username exists yet." }, status: :not_found
    else
      render json: { error: "Invalid username or password" }, status: :unauthorized
    end
  end

  def show
    if logged_in?
      render json: current_user, status: :accepted
    else
      render json: { error: "User is not logged in/could not be found." }, status: :unauthorized
    end
  end

  private

  def session_params
    params.require(:session).permit(:username, :password)
  end
end

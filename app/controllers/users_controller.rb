# frozen_string_literal: true

class UsersController < ApplicationController
  wrap_parameters :user,
                  include: %i[full_name username password workplace bartender instagram_account avatar]

  def index
    users = User.includes(:bars, :cocktails, :likes, :followed_users, :following_users, :image_attachment).order(:id)
    render json: users, except: %i[created_at updated_at]
  end

  def show
    user = User.find(params[:id])
    render json: user, except: %i[created_at updated_at]
  end

  def signup
    user = User.create(user_params)

    if user.save
      token = issue_token(user)
      render json: { user: UserSerializer.new(user), jwt: token }, status: :created
    elsif user.errors.messages
      render json: { errors: user.errors.messages }, status: :unprocessable_entity
    else
      render json: { error: 'User could not be created. Please try again.' }, status: :unprocessable_entity
    end

    return unless params[:work_at]

    bar = Bar.find_by(name: params[:work_at])
    bar = Bar.create(name: params[:work_at]) if bar.nil?
    @workplace = Workplace.create(bar_id: bar.id, bartender_id: user.id)
  end

  def me
    render json: current_user
  end

  def update
    updated_params = user_params.except(:avatar)
    current_user.assign_attributes(updated_params)

    if user_params[:avatar].present?
      upload_errors = current_user.image_upload_errors(user_params[:avatar])
      return render json: { errors: upload_errors }, status: :unprocessable_entity if upload_errors.any?

      current_user.attach_image(user_params[:avatar])
    end

    if current_user.save
      render json: current_user
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.destroy
    render json: { message: 'User deleted.' }, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :username, :password, :location, :bartender, :avatar)
  end
end

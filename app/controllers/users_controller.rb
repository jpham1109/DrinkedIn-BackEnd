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
      # invoke issue_token helper method defined in ApplicationController
      token = issue_token(user)
      render json: { user: UserSerializer.new(user), jwt: token }, status: :created
    elsif user.errors.messages
      render json: { errors: user.errors.messages }, status: :unprocessable_entity
    else
      render json: { error: 'User could not be created. Please try again.' }, status: :unprocessable_entity
    end

    if user.instagram_account
      insta_info = user.instagram_info
      user.update(biography: insta_info['data']['user']['biography'],
                  insta_follower: insta_info['data']['user']['edge_followed_by']['count'], insta_following: insta_info['data']['user']['edge_follow']['count'], profile_pic: insta_info['data']['user']['profile_pic_url'])
    end

    return unless params[:work_at]

    bar = Bar.find_by(name: params[:work_at])

    if bar.nil?
      bar = Bar.create(name: params[:work_at])
      bar.update(address: bar.address, website: bar.website, rating: bar.rating, total_ratings: bar.total_ratings,
                 photos: bar.photo_array, reviews: bar.reviews)
    end

    @workplace = Workplace.create(bar_id: bar.id, bartender_id: user.id)
  end

  def me
    # token present in headers would be used to find the current user
    render json: current_user
  end

  def update
    # token present in headers would be used to find the current user
    # prepare user params without avatar for updating
    updated_params = user_params.except(:avatar)
    # update the user with the prepared params
    if current_user.update(updated_params)
      # attach or update the avatar if present
      current_user.attach_image(user_params[:avatar]) if user_params[:avatar].present?
      render json: current_user
    else
      render json: { error: 'failed to update user' }, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.destroy
    render json: { message: 'User deleted.' }, status: :ok
  end

  private

  def user_params
    # omit id from user params for security
    params.require(:user).permit(:full_name, :username, :password, :location, :bartender, :avatar)
  end
end

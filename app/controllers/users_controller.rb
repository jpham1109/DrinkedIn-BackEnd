class UsersController < ApplicationController
  wrap_parameters :user, include: [:full_name, :username, :password, :workplace, :bartender, :instagram_account, :avatar]

  def index
    users = User.includes(:bars, :cocktails, :likes, :followed_users, :following_users).order(:id)
    render json: users, except: [:created_at, :updated_at]
  end

  def show
    user = User.find(params[:id])
    render json: user, except: [:created_at, :updated_at]
  end

  def signup
    user = User.create(user_params)

    if user.save
      #invoke issue_token helper method defined in ApplicationController
      token = issue_token(user)
      render json: { user: UserSerializer.new(user), jwt: token }, status: :created
    else
      if user.errors.messages
        render json: { errors: user.errors.messages }, status: :unprocessable_entity
      else
        render json: { error: "User could not be created. Please try again." }, status: :unprocessable_entity
      end
    end

    if user.instagram_account
      insta_info = user.instagram_info
      user.update(biography: insta_info["data"]["user"]["biography"], insta_follower: insta_info["data"]["user"]["edge_followed_by"]["count"], insta_following: insta_info["data"]["user"]["edge_follow"]["count"], profile_pic: insta_info["data"]["user"]["profile_pic_url"])
    end

    if params[:work_at]
      bar = Bar.find_by(name: params[:work_at])

      if bar.nil?
        bar = Bar.create(name: params[:work_at])
        bar.update(address: bar.address, website: bar.website, rating: bar.rating, total_ratings: bar.total_ratings, photos: bar.photo_array, reviews: bar.reviews)
      end

      @workplace = Workplace.create(bar_id: bar.id, bartender_id: user.id)
    end
  end

  def me
    render json: current_user
  end

  def update
    user = User.find(user_params[:id])

    #attach avatar if there is one
    if user_params[:avatar]
      attach_avatar(user, user_params[:avatar])
      # Remove avatar from user_params
      user_params_without_avatar = user_params.except(:avatar)
      user.update(user_params_without_avatar)
    else
      user.update(user_params)
    end

    render json: user
  end

  def destroy
    current_user.destroy
    render json: { message: "User deleted." }, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :username, :password, :location, :bartender, :avatar, :id)
  end

  def attach_avatar(user, avatar_params)
    return unless avatar_params

    if avatar_params.is_a?(ActionDispatch::Http::UploadedFile)
      user.avatar.attach(avatar_params)
    elsif avatar_params.is_a?(String) && avatar_params.starts_with?("data:image")
      blob = ActiveStorage::Blob.create_after_upload!(
        io: StringIO.new((Base64.decode64(avatar_params.split(",")[1]))),
        filename: "user_avatar.png",
        content_type: "image/png",
      )
      user.avatar.attach(blob)
    else
      return
    end
    user.update(profile_pic: url_for(user.avatar))
  end
end

class UsersController < ApplicationController
    before_action :authenticate, only: [:me, :update]
# Auth is working
    def index
        @users = User.order(:id)
        render json: @users
    end

    def show 
        @user = User.find(params[:id])
        render json: @user
    end 

    def login
        # Look up a user with username and password
        # user = User.first
        user = User.find_by(username: params[:username])
        # We want to check if the user exist and authenticate
        if user && user.authenticate(params[:password])
            token = JWT.encode({ user_id: user.id }, 'my_secret', 'HS256')
            render json: { user: UserSerializer.new(user), token: token }
        else
            render json: { errors: ["Invalid username or password"] }, status: :unauthorized
        end
    end

    def signup
        #when the user created, we also issue them a token. We send back respond user and token
        user = User.create(user_params)
        
        if user.valid?
            token = JWT.encode({ user_id: user.id }, 'my_secret', 'HS256')
            render json: { user: UserSerializer.new(user), token: token }, status: :created
        else
            render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end

        insta_info = user.instagram_info
        user.update(biography: insta_info["data"]["user"]["biography"], insta_follower: insta_info["data"]["user"]["edge_followed_by"]["count"], insta_following: insta_info["data"]["user"]["edge_follow"]["count"], profile_pic: insta_info["data"]["user"]["profile_pic_url"] )

        if user.work_at
            user.update(workplace_photos: user.workplace_photo_array, workplace_rating: user.workplace_rating, workplace_reviews: user.workplace_reviews, workplace_ratings_total: user.workplace_ratings_total)
        end
        
    end

    def me
        # TODO: check some identifying info about request (token header)
        # user = User.first
        render json: @current_user
    end

    def update
        @current_user.update(full_name: params[:full_name], username: params[:username], password: params[:password], location: params[:location], bartender: params[:bartender], work_at: params[:work_at], instagram_account: params[:instagram_account])
        render json: @current_user
    end

    private 

    def user_params
        params.permit(:full_name, :username, :password, :location, :bartender, :work_at, :instagram_account)
    end
end

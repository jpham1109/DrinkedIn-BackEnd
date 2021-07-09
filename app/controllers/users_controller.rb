class UsersController < ApplicationController
    before_action :authenticate, only: [:me, :update]

    def index
        @users = User.order(:id).preload([:followed_users, :following_users, :cocktails, :cocktail, :category, :likes])
        render json: @users
    end

    def show 
        @user = User.find(params[:id])
        render json: @user
    end 

    def login
        
        @users = User.order(:id).includes(:followed_users, :following_users, likes: [:liked_cocktail], cocktails: [:category, :likes])
        user = @users.find_by(username: params[:username])
        @cocktails = user.cocktails.includes([:category, :likes])
        @likes = user.likes.includes([:liked_cocktail])
        # @follows = user.follows.includes([:follower, :followee])
        
        if user && user.authenticate(params[:password])
            token = JWT.encode({ user_id: user.id }, 'my_secret', 'HS256')
            render json: { user: UserSerializer.new(user), token: token }
        else
            render json: { errors: ["Invalid username or password"] }, status: :unauthorized
        end
    end

    def signup
       
        user = User.create(user_params)
        # byebug
        if user.valid?
            token = JWT.encode({ user_id: user.id }, 'my_secret', 'HS256')
            render json: { user: UserSerializer.new(user), token: token }, status: :created
        else
            render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
        
        if user.instagram_account
            insta_info = user.instagram_info
            user.update(biography: insta_info["data"]["user"]["biography"], insta_follower: insta_info["data"]["user"]["edge_followed_by"]["count"], insta_following: insta_info["data"]["user"]["edge_follow"]["count"], profile_pic: insta_info["data"]["user"]["profile_pic_url"] )
        end

        if user.work_at
            @bar = Bar.find_by(name: user.work_at)

            if @bar.nil?
                @bar = Bar.create(name: user.work_at)
                @bar.update(address: @bar.address, rating: @bar.rating, total_ratings: @bar.total_ratings, photos: @bar.photo_array, reviews: @bar.reviews )   
            end

            @workplace = Workplace.create(bar_id: @bar.id, bartender_id: user.id)
           
        end
        
    end

    def me
        
        render json: @current_user
        #  UserSerializer.new(@current_user)
    end

    def update
        @current_user.update(full_name: params[:full_name], username: params[:username], password: params[:password], location: params[:location], bartender: params[:bartender], work_at: params[:work_at], instagram_account: params[:instagram_account])
        @likes = @current_user.likes.includes([:cocktail])
        # if @current_user.instagram_account
        #     user = User.find(@current_user.id)
        #     insta_info = user.instagram_info
        #     # byebug
        #     user.update(biography: insta_info["data"]["user"]["biography"], insta_follower: insta_info["data"]["user"]["edge_followed_by"]["count"], insta_following: insta_info["data"]["user"]["edge_follow"]["count"], profile_pic: insta_info["data"]["user"]["profile_pic_url_hd"] )
        # end

        if @current_user.work_at
            # byebug
            user = User.find(@current_user.id)
            user.update!(workplace_photos: user.workplace_photo_array, workplace_rating: user.workplace_rating, workplace_reviews: user.workplace_reviews, workplace_ratings_total: user.workplace_ratings_total, workplace_id: user.workplace_id, workplace_address: user.workplace_address)
        end
        render json: @current_user
    end

    private 

    def user_params
        params.permit(:full_name, :username, :password, :location, :bartender, :work_at, :instagram_account)
    end

   
end

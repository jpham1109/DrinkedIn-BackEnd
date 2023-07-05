class UsersController < ApplicationController
    before_action :authenticate, only: [:me, :update]

    def index
        @users = User.order(:id)
        render json: @users, except: [:created_at, :updated_at]
    end

    def show 
        @user = User.find(params[:id])
        render json: @user, except: [:created_at, :updated_at]
    end 

    def login
        
        @users = User.order(:id)
        # .includes(:followed_users, :following_users, likes: [:liked_cocktail], cocktails: [:category, :likes])
        user = @users.find_by(username: params[:username])
        # @cocktails = user.cocktails.includes([:category, :likes])
        # @likes = user.likes.includes([:liked_cocktail])
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

        if params[:work_at]
            @bar = Bar.find_by(name: params[:work_at])

            if @bar.nil?
                @bar = Bar.create(name: params[:work_at])
                @bar.update(address: @bar.address, website: @bar.website, rating: @bar.rating, total_ratings: @bar.total_ratings, photos: @bar.photo_array, reviews: @bar.reviews )   
            end
          
            @workplace = Workplace.create(bar_id: @bar.id, bartender_id: user.id)
           
        end
        
    end

    def me
        
        render json: @current_user
         UserSerializer.new(@current_user)
    end

    def update
        # byebug
        @current_user.update(full_name: params[:full_name], username: params[:username], password: params[:password], location: params[:location], bartender: params[:bartender], instagram_account: params[:instagram_account])
        # @likes = @current_user.likes.includes([:cocktail])
        # if @current_user.instagram_account
        #     user = User.find(@current_user.id)
        #     insta_info = user.instagram_info
        #     # byebug
        #     user.update(biography: insta_info["data"]["user"]["biography"], insta_follower: insta_info["data"]["user"]["edge_followed_by"]["count"], insta_following: insta_info["data"]["user"]["edge_follow"]["count"], profile_pic: insta_info["data"]["user"]["profile_pic_url_hd"] )
        # end

        if params[:work_at]
            # byebug
            user = User.find(@current_user.id)
            @bar = Bar.find_by(name: params[:work_at])

            if @bar.nil?
                @bar = Bar.create(name: params[:work_at])
                @bar.update(address: @bar.address, website: @bar.website, rating: @bar.rating, total_ratings: @bar.total_ratings, photos: @bar.photo_array, reviews: @bar.reviews )   
            end
            
            @workplace = Workplace.create(bar_id: @bar.id, bartender_id: user.id)
        end
        render json: @current_user
    end

    private 

    def user_params
        # investigate why `require(:user)` prevents user from being created: Password comes out blank
        params.permit(:full_name, :username, :password, :location, :bartender, :instagram_account)
    end

   
end

class UsersController < ApplicationController
    # before_action :authenticate, only: [:me, :update] (moved to application_controller.rb)

    def index
        @users = User.order(:id)
        render json: @users, except: [:created_at, :updated_at]
    end

    def show 
        @user = User.find(params[:id])
        render json: @user, except: [:created_at, :updated_at]
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
        if @current_user.instagram_account
            user = User.find(@current_user.id)
            insta_info = user.instagram_info
            # byebug
            user.update(biography: insta_info["data"]["user"]["biography"], insta_follower: insta_info["data"]["user"]["edge_followed_by"]["count"], insta_following: insta_info["data"]["user"]["edge_follow"]["count"], profile_pic: insta_info["data"]["user"]["profile_pic_url_hd"] )
        end

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
        params.require(:user).permit(:full_name, :username, :password, :location, :bartender, :instagram_account, :user)
    end

   
end

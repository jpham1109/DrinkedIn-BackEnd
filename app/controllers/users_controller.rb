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

    #POST /login
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

        insta_api_url= "https://instagram28.p.rapidapi.com/user_info?user_name=#{user.instagram_account}"
        response = Faraday.get(insta_api_url, {"x-rapidapi-host" => "instagram28.p.rapidapi.com"}, {"x-rapidapi-key" => ENV['INSTA_KEY']})
        # res = JSON.parse(response.body)
        # res["candidates"][0]["place_id"]

        if user.work_at
             
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
        params.permit(:full_name, :username, :password, :location, :bartender, :work_at, :instagram_account, :image)
    end
end

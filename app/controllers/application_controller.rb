class ApplicationController < ActionController::API

    #secret key saved away in a credentials file
    def jwt_key
        Rails.application.credentials.jwt_key
    end

    #method to encode a token for a user when they login or signup
    def issue_token(user)
        JWT.encode({user_id: user.id}, jwt_key, 'HS256')
    end

    #method to decode a token given to us by the client
    def decoded_token
        begin
            JWT.decode(token, jwt_key, true, { :algorithm => 'HS256' })
        rescue JWT::DecodeError
            [{error: "Invalid Token"}]
        end
    end

    #method to get the token from the client
    def token
        request.headers['Authorization']
    end

    #method to get the current user based on the token
    def current_user
        user_id = decoded_token.first['user_id']
        User.find_by(id: user_id)
        
    end

    #method to check if the user is logged in
    def logged_in?
        !!current_user
    end
end

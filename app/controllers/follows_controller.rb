class FollowsController < ApplicationController

    def index
        @follows = Follow.order(:id)
        render json: @follows
    end

    def create
       
        @follow = Follow.create(follower_id: params["user_id"], followee_id: params["current_user_id"])
        render json: @follow
    end

    def destroy
    end
end

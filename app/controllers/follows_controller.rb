class FollowsController < ApplicationController

    def index
        @follows = Follow.order(:id).includes([:follower, :followee])
        render json: @follows
    end

    def create
       
        @follow = Follow.create(follower_id: params["user_id"], followee_id: params["current_user_id"])
        render json: @follow
    end

    def destroy
        @follow = Follow.find(params[:id])
        @follow.destroy!
        render json: @follow
    end
end

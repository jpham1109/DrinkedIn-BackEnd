class FollowsController < ApplicationController
  def index
    @follows = Follow.order(:id).includes([:follower, :followee])
    render json: @follows
  end

  def show
    @follow = Follow.find(params[:id])
    render json: @follow
  end

  def create
    @follow = Follow.create(follower_id: params["follower_id"], followee_id: params["followee_id"])
    render json: @follow
  end

  def destroy
    @follow = Follow.find(params[:id])
    @follow.destroy!
    render json: {}, status: :no_content
  end
end

# frozen_string_literal: true

class FollowsController < ApplicationController
  before_action :require_login, only: %i[create destroy]
  before_action :find_follow, only: %i[show destroy]
  before_action :require_follow_participant, only: %i[destroy]

  def index
    @follows = Follow.order(:id).includes(%i[follower followee])
    render json: @follows
  end

  def show
    render json: @follow
  end

  def create
    @follow = Follow.create(follower_id: current_user.id, followee_id: params['followee_id'])
    render json: @follow
  end

  def destroy
    @follow.destroy!
    render json: {}, status: :no_content
  end

  private

  def find_follow
    @follow = Follow.find(params[:id])
  end

  # Either side of a Follow relationship may end it: the follower
  # (unfollow) or the followee (remove follower). An unrelated
  # authenticated user stays forbidden — only destroy touches this, so
  # there's no case where a non-participant should be able to delete it.
  def require_follow_participant
    return if [@follow.follower_id, @follow.followee_id].include?(current_user.id)

    render json: { error: 'Forbidden' }, status: :forbidden
  end
end

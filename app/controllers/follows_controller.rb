# frozen_string_literal: true

class FollowsController < ApplicationController
  before_action :require_login, only: %i[create destroy]
  before_action :find_follow, only: %i[show destroy]
  before_action :require_follow_owner, only: %i[destroy]

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

  def require_follow_owner
    render json: { error: 'Forbidden' }, status: :forbidden unless @follow.follower_id == current_user.id
  end
end

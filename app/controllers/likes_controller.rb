# frozen_string_literal: true

class LikesController < ApplicationController
  before_action :require_login, only: %i[create destroy]
  before_action :find_like, only: %i[show destroy]
  before_action :require_like_owner, only: %i[destroy]

  def index
    @likes = Like.order(:id).includes(%i[liked_cocktail liker])
    render json: @likes
  end

  def show
    render json: @like
  end

  def create
    @like = Like.create(liker_id: current_user.id, liked_cocktail_id: params['liked_cocktail_id'])
    render json: @like
  end

  def destroy
    @like.destroy!
    render json: {}, status: :no_content
  end

  private

  def find_like
    @like = Like.find(params[:id])
  end

  def require_like_owner
    render json: { error: 'Forbidden' }, status: :forbidden unless @like.liker_id == current_user.id
  end
end

# frozen_string_literal: true

class FavoritesController < ApplicationController
  before_action :require_login
  before_action :find_favorite, only: %i[destroy]
  before_action :require_favorite_owner, only: %i[destroy]

  def index
    @favorites = Favorite.where(user_id: current_user.id)
    render json: @favorites
  end

  def create
    @favorite = Favorite.create(user_id: current_user.id, favorited_bar_id: params['favorited_bar_id'])
    render json: @favorite
  end

  def destroy
    @favorite.destroy!
    render json: {}, status: :no_content
  end

  private

  def find_favorite
    @favorite = Favorite.find(params[:id])
  end

  def require_favorite_owner
    render json: { error: 'Forbidden' }, status: :forbidden unless @favorite.user_id == current_user.id
  end
end

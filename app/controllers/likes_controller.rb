class LikesController < ApplicationController
  def index
    @likes = Like.order(:id).includes([:liked_cocktail, :liker])
    render json: @likes
  end

  def show
    @like = Like.find(params[:id])
    render json: @like
  end

  def create
    # byebug
    @like = Like.create(liker_id: params["liker_id"], liked_cocktail_id: params["liked_cocktail_id"])
    render json: @like
  end

  def destroy
    @like = Like.find(params[:id])
    @like.destroy!
    render json: {}, status: :no_content
  end

  private

  def find_cocktail
    @cocktail = Cocktail.find(params["liked_cocktail_id"])
  end
end

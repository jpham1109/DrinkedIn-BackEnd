class LikesController < ApplicationController
    before_action :find_cocktail, only: [:create]

    def index 
        @likes = Like.order(:id).includes([:liked_cocktail])
        render json: @likes
    end

    def show
        @like = Like.find(params[:id])
        render json: @like
    end

    def create 
        # byebug
        @like = Like.create(liker_id: params["liker_id"], liked_cocktail_id: params["liked_cocktail_id"])
        render json: @cocktail
    end 

    def destroy
        @like = Like.find_by(liked_cocktail_id: params[:id])
        @like.destroy!
        render json: @like
    end

    private 

    def find_cocktail
        @cocktail = Cocktail.find(params["liked_cocktail_id"])
    end
end

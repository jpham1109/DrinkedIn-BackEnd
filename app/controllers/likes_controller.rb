class LikesController < ApplicationController
    before_action :find_cocktail, only: [:create]

    def index 
        @likes = Like.order(:id)
        render json: @likes
    end

    def show
        @like = Like.find(params[:id])
        render json: @like
    end

    def create 
        # byebug
        @like = Like.create(user_id: params["user_id"], cocktail_id: params["cocktail_id"])
        render json: @cocktail
    end 

    private 

    def find_cocktail
        @cocktail = Cocktail.find(params["cocktail_id"])
    end
end

class CocktailsController < ApplicationController
    before_action :find_destination, only: [:create]

    def index
        @cocktails = Cocktail.order(:id)
        render json: @cocktails
    end 

    def show 
        @cocktail = Cocktail.find(params[:id])
        render json: @cocktail
    end

    def create 
        @cocktail = Cocktail.create(user_id: params["user_id"], category_id: params["category_id"]) 
        render json: @cocktail
    end 

    def destroy
        @cocktail = Cocktail.find(params[:id])
        @cocktail.destroy
        render json: @cocktail
    end 
    
    private

    def find_category
        @category = Category.find(params["category_id"])
    end
end

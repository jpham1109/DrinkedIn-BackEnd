class CocktailsController < ApplicationController
    before_action :find_category, only: [:create, :update]
    # before_action :find_category, only: [:update]
    def index
        @cocktails = Cocktail.order(:id).includes(:category, :user, :likes).where(user: {bartender: true})
        render json: @cocktails
    end 

    def show 
        cocktail = Cocktail.includes(:category, :user, :likes).find(params[:id])
        render json: cocktail
    end

    def create 
        cocktail = Cocktail.create(user_id: params[:user_id], category_id: @category.id, name: params[:name], description: params[:description], execution: params[:execution], ingredients: params[:ingredients]) 
        
        if cocktail.valid?
            render json: cocktail, status: :created
            puts cocktail
        else
            render json: { error: 'failed to create cocktail' }, status: :not_acceptable
        end 
    end

    def update
        # byebug
        cocktail = Cocktail.find(params[:id])
        # @category = Category.find_by(name: params[:category])
        cocktail.update(category_id: @category.id, name: params[:name], description: params[:description], execution: params[:execution], ingredients: params[:ingredients])
        # cocktail.update(photo: params[:photo])
        # photo_url = rails_blob_path(cocktail.photo)
        # render json: {cocktail: cocktail, photo_url: photo_url}
        render json: cocktail
    end

    def destroy
        cocktail = Cocktail.find(params[:id])
        cocktail.destroy
        render json: cocktail
    end 
    
    private 

    def cocktail_params
        params.permit(:id, :name, :description, :execution, :ingredients, :photo)
    end 

    def find_category
        @category = Category.find_by(name: params[:category])
    end

end

class CocktailsController < ApplicationController
    before_action :find_category, only: [:create]
    before_action :cocktail_params, only: [:update]
    def index
        @cocktails = Cocktail.all
        render json: @cocktails
    end 

    def show 
        cocktail = Cocktail.find(params[:id])
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
        cocktail.update(cocktail_params)
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
        params.permit(:id, :name, :description, :execution, :ingredients, :photo, :category)
    end 

    def find_category
        @category = Category.find_by(name: params[:category])
    end

end

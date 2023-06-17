class CocktailsController < ApplicationController
    before_action :find_category, only: [:create]
    # before_action :find_category, only: [:update]
    def index
        @cocktails = Cocktail.order(:id).includes(:category)
        # .includes(:category, :bartender, :likes).where(user: {bartender: true})
        render json: @cocktails
    end 

    def show 
        cocktail = Cocktail.includes(:category, :likes).find(params[:id])
        render json: cocktail, except: [:created_at, :updated_at]
    end

    def create 
        cocktail = Cocktail.create(bartender_id: params[:user_id], category_id: @category.id, name: params[:name], description: params[:description], execution: params[:execution], ingredients: params[:ingredients]) 
        
        if cocktail.valid?
            render json: cocktail, status: :created
            puts cocktail
        else
            render json: { error: 'failed to create cocktail' }, status: :not_acceptable
        end 
    end

    def update
        
        cocktail = Cocktail.find(params[:id])
        if params["category"]["id"]
            cocktail.update(name: params[:name], description: params[:description], execution: params[:execution], ingredients: params[:ingredients])
        else
        @category = Category.find_by(name: params[:category])
        cocktail.update(category_id: @category.id, name: params[:name], description: params[:description], execution: params[:execution], ingredients: params[:ingredients])
        end
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

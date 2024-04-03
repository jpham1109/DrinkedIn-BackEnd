# frozen_string_literal: true

class CocktailsController < ApplicationController
  before_action :find_cocktail, only: %i[show update destroy]
  before_action :convert_to_array, only: %i[create update]
  wrap_parameters :cocktail, include: %i[name description execution ingredients category user_id image]

  def index
    # Eager load the :category, :bartender, and :image_attachment associations
    cocktails = Cocktail.includes(:category, :bartender, image_attachment: :blob).order(created_at: :desc)
    render json: cocktails
  end

  def show
    render json: @cocktail, except: %i[created_at updated_at]
  end

  def create
    # create cocktail without the photo parameter
    cocktail = Cocktail.new(cocktail_params.except(:photo))
    cocktail.bartender_id = cocktail_params[:user_id]
    cocktail.category_id = cocktail_params[:category_id]
    cocktail.ingredients = @ingredients_array

    if cocktail.save
      cocktail.attach_image(cocktail_params[:photo]) if cocktail_params[:photo].present?
      render json: cocktail, status: :created
    else
      render json: { error: 'failed to create cocktail' }, status: :not_acceptable
    end
  end

  def update
    # prepare params without photo for updating
    updated_params = cocktail_params.except(:photo)
    # check if ingredients are present and use the converted array
    updated_params[:ingredients] = @ingredients_array if cocktail_params[:ingredients].present?
    # update the cocktail with the prepared params
    if @cocktail.update(updated_params)
      # attach or update the image if present, using the concern's method
      @cocktail.attach_image(cocktail_params[:photo]) if cocktail_params[:photo].present?
      render json: @cocktail
    else
      render json: { error: 'failed to update cocktail' }, status: :unprocessable_entity
    end
  end

  def destroy
    @cocktail.destroy
    # Respond with an empty JSON object and a status of 204 No Content
    render json: {}, status: :no_content
  end

  private

  def cocktail_params
    params.require(:cocktail).permit(:id, :name, :description, :execution, :ingredients, :category_id, :user_id, :photo)
  end

  def convert_to_array
    @ingredients_array = if cocktail_params[:ingredients].instance_of?(String)
                           cocktail_params[:ingredients].split(',').map(&:strip)
                         else
                           cocktail_params[:ingredients]
                         end
  end

  def find_cocktail
    @cocktail = Cocktail.find(params[:id])
  end
end

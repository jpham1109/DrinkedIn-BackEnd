# frozen_string_literal: true

class CocktailsController < ApplicationController
  before_action :require_login, only: %i[create update destroy]
  before_action :find_cocktail, only: %i[show update destroy]
  before_action :require_cocktail_owner, only: %i[update destroy]
  before_action :convert_to_array, only: %i[create update]
  wrap_parameters :cocktail, include: %i[name description execution ingredients category image]

  def index
    cocktails = Cocktail.includes(:category, :bartender, image_attachment: :blob).order(created_at: :desc)
    render_collection(cocktails)
  end

  def show
    render_success(@cocktail)
  end

  def create
    cocktail = Cocktail.new(cocktail_params.except(:photo))
    cocktail.bartender_id = current_user.id
    cocktail.category_id = cocktail_params[:category_id]
    cocktail.ingredients = @ingredients_array

    if cocktail_params[:photo].present?
      upload_errors = cocktail.image_upload_errors(cocktail_params[:photo])
      return render_upload_errors(upload_errors) if upload_errors.any?

      cocktail.attach_image(cocktail_params[:photo])
    end

    if cocktail.save
      render_success(cocktail, status: :created)
    else
      render_validation_errors(cocktail)
    end
  end

  def update
    updated_params = cocktail_params.except(:photo)
    updated_params[:ingredients] = @ingredients_array if cocktail_params[:ingredients].present?
    @cocktail.assign_attributes(updated_params)

    if cocktail_params[:photo].present?
      upload_errors = @cocktail.image_upload_errors(cocktail_params[:photo])
      return render_upload_errors(upload_errors) if upload_errors.any?

      @cocktail.attach_image(cocktail_params[:photo])
    end

    if @cocktail.save
      render_success(@cocktail)
    else
      render_validation_errors(@cocktail)
    end
  end

  def destroy
    @cocktail.destroy
    head :no_content
  end

  private

  def cocktail_params
    params.require(:cocktail).permit(:id, :name, :description, :execution, :ingredients, :category_id, :photo)
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

  def require_cocktail_owner
    return if @cocktail.bartender_id == current_user.id

    render_error(
      code: 'forbidden',
      message: 'You are not authorized to modify this cocktail.',
      status: :forbidden
    )
  end
end

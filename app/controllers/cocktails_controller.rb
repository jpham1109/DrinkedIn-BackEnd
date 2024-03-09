class CocktailsController < ApplicationController
  before_action :find_cocktail, only: [:show, :update, :destroy]
  before_action :convert_to_array, only: [:create, :update]
  wrap_parameters :cocktail, include: [:name, :description, :execution, :ingredients, :category, :user_id, :image]

  def index
    cocktails = Cocktail.order(created_at: :desc)
    render json: cocktails
  end

  def show
    render json: @cocktail, except: [:created_at, :updated_at]
  end

  def create

    # create cocktail
    cocktail = Cocktail.create(bartender_id: cocktail_params[:user_id], category_id: cocktail_params[:category_id], name: cocktail_params[:name], description: cocktail_params[:description], execution: cocktail_params[:execution], ingredients: @ingredients_array, photo: cocktail_params[:photo])

    if cocktail.valid?
      render json: cocktail, status: :created
    else
      render json: { error: "failed to create cocktail" }, status: :not_acceptable
    end
  end

  def update
    # adjust when update Form is optimized
    if cocktail_params[:photo]
      @cocktail.update(photo: cocktail_params[:photo])
      # remove photo from cocktail_params
      cocktail_params_without_photo = cocktail_params.except(:photo)
      @cocktail.update(cocktail_params_without_photo)
    elsif cocktail_params[:ingredients]
      @cocktail.update(ingredients: @ingredients_array)
      # remove ingredients from cocktail_params
      cocktail_params_without_ingredients = cocktail_params.except(:ingredients)
      @cocktail.update(cocktail_params_without_ingredients)
      # elsif cocktail_params[:category]
      #   @cocktail.update(category_id: @category.id)
      #   # remove category from cocktail_params
      #   cocktail_params_without_category = cocktail_params.except(:category)
      #   @cocktail.update(cocktail_params_without_category)
    end
    render json: @cocktail
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

  def attach_photo(cocktail, photo_params)
    return unless photo_params

    if photo_params.is_a?(ActionDispatch::Http::UploadedFile)
      cocktail.photo.attach(photo_params)
    elsif photo_params.is_a?(String) && photo_params.starts_with?("data:image")
      blob = ActiveStorage::Blob.create_after_upload!(
        io: StringIO.new((Base64.decode64(photo_params.split(",")[1]))),
        filename: "cocktail_photo.png",
        content_type: "image/png",
      )
      cocktail.photo.attach(blob)
    else
      return
    end
    cocktail.update(image: url_for(cocktail.photo))
  end

  def convert_to_array
    if cocktail_params[:ingredients].class == String
      @ingredients_array = cocktail_params[:ingredients].split(",").map(&:strip)
    else
      @ingredients_array = cocktail_params[:ingredients]
    end
  end

  def find_category
    @category = Category.find_by(name: cocktail_params[:category])
  end

  def find_cocktail
    @cocktail = Cocktail.find(params[:id])
  end
end

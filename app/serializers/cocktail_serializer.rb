class CocktailSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  attributes :id, :name, :description, :ingredients, :execution, :image, :photo_url, :bartender_id, :likes_count
  belongs_to :category, serializer: CategoryPreviewSerializer
  belongs_to :bartender, serializer: BartenderSerializer

  def photo_url
    object.photo.attached? ? Rails.application.routes.url_helpers.url_for(object.photo) : nil
  end
end

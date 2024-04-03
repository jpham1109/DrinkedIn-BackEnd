# frozen_string_literal: true

class CocktailSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  attributes :id, :name, :description, :ingredients, :execution, :photo, :bartender_id, :likes_count
  belongs_to :category, serializer: CategoryPreviewSerializer
  belongs_to :bartender, serializer: BartenderSerializer

  def photo
    object.processed_image_url
  end
end

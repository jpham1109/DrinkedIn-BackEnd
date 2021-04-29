class CocktailSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  attributes :id, :name, :description, :ingredients, :image, :likes
  has_one :user
  has_one :category

  def image 
    if object.image.attached?
      {
        url: rails_blob_url(object.image)
      }
  end

end

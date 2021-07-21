class CocktailSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  attributes :id, :name, :description, :ingredients, :execution, :image, :likes_count, :bartender_id, :category
  # has_one :user
  # has_one :category

  # def photo
  #   rails_blob_path(object.photo, only_path: true) if object.photo.attached?
  # end

  # # def photo
    
  # #   return unless object.photo.attached?

  # #   object.photo.blob.attributes
  # #         .slice('filename', 'byte_size')
  # #         .merge(url: photo_url)
  # #         .tap { |attrs| attrs['name'] = attrs.delete('filename') }
  # # end

  # def photo_url
  #   # byebug
  #   url_for(object.photo)
  #   # rails_blob_path(object.photo, only_path: true) if object.photo.attached
  # end

end

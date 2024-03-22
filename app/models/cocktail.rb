class Cocktail < ApplicationRecord
  belongs_to :bartender, class_name: "User"
  class UserSerializer < ActiveModel::Serializer
    attributes :id, :full_name
  end
  
  belongs_to :category

  has_many :likes, foreign_key: "liked_cocktail_id", dependent: :destroy
  has_many :likers, :through => :likes, :class_name => "User"

  has_one_attached :photo

  def photo_url
    Rails.application.routes.url_helpers.url_for(photo) if photo.attached?
  end
end

# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :username, :location, :bartender, :avatar

  has_many :bars
  # override the bars method to only return the ids of the bars
  class BarSerializer < ActiveModel::Serializer
    attributes :id
  end

  has_many :cocktails
  # override the cocktails method to only return the ids of the cocktails
  class CocktailSerializer < ActiveModel::Serializer
    attributes :id
  end

  has_many :likes

  has_many :favorites
  # override the favorites method to only return the ids of the favorites
  class FavoriteSerializer < ActiveModel::Serializer
    attributes :id
  end

  has_many :followed_users

  has_many :following_users

  def avatar
    object.processed_image_url
  end
end

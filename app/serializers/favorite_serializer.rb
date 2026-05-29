# frozen_string_literal: true

class FavoriteSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :favorited_bar_id
  has_one :user
end

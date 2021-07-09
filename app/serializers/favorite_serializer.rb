class FavoriteSerializer < ActiveModel::Serializer
  attributes :id, :liked_bar_id
  has_one :user
end

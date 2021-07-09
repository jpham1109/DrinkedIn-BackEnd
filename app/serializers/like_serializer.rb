class LikeSerializer < ActiveModel::Serializer
  attributes :id
  has_one :liked_cocktail
end

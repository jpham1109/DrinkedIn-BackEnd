class LikeSerializer < ActiveModel::Serializer
  attributes :id, :liked_cocktail_id
  has_one :liked_cocktail
end

# frozen_string_literal: true

class LikeSerializer < ActiveModel::Serializer
  attributes :id, :liked_cocktail_id
end

class BarSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :photos, :rating, :total_ratings, :reviews
end

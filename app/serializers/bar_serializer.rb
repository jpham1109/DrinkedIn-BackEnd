# frozen_string_literal: true

class BarSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :website, :photos, :rating, :total_ratings, :reviews
end

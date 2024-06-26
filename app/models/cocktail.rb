# frozen_string_literal: true

class Cocktail < ApplicationRecord
  belongs_to :bartender, class_name: 'User'
  class UserSerializer < ActiveModel::Serializer
    attributes :id, :full_name
  end

  belongs_to :category

  has_many :likes, foreign_key: 'liked_cocktail_id', dependent: :destroy
  has_many :likers, through: :likes, class_name: 'User'

  # concern for image attachment
  include ImageAttachable
  has_one_attached :image
end

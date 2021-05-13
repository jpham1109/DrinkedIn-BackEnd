class Cocktail < ApplicationRecord
  belongs_to :user
  belongs_to :category

  has_many :likes, dependent: :destroy
  # has_many :likers, through: :likes, class_name: 'User'
  
  
  has_one_attached :photo

  
  
end

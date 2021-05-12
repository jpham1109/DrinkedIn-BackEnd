class Cocktail < ApplicationRecord
  belongs_to :user
  belongs_to :category

  has_many :likes
  # has_many :likers, through: :likes, class_name: 'User'

  has_one_attached :photo

  def likes_count
    likes.length
  end 

  def creator
    user.full_name
  end
  # validates :image, attached: true
end

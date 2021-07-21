class Cocktail < ApplicationRecord
  belongs_to :bartender, class_name: 'User'
  belongs_to :category

  has_many :likes, foreign_key: "liked_cocktail_id", dependent: :destroy
  has_many :likers, :through => :likes, :class_name => "User"
  
  has_one_attached :photo

  def likes_count
    self.likes.size
  end

end

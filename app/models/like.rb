# frozen_string_literal: true

class Like < ApplicationRecord
  belongs_to :liker, class_name: 'User'
  belongs_to :liked_cocktail, class_name: 'Cocktail', counter_cache: :likes_count

  validates :liker_id, uniqueness: { scope: :liked_cocktail_id, message: 'You may only like a cocktail once' }
end

class Like < ApplicationRecord
  belongs_to :user
  belongs_to :cocktail
  validates :user_id, uniqueness: { scope: :cocktail_id, message: "You may only like a cocktail once"}
end

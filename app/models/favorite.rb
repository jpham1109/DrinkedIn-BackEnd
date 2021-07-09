class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :favorited_bar, class_name: 'Bar'
  validates :user_id, uniqueness: { scope: :favorited_bar_id, message: "already exist"}
end

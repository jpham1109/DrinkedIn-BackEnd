# frozen_string_literal: true

class User < ApplicationRecord
  has_many :cocktails, foreign_key: 'bartender_id', dependent: :destroy
  has_many :categories, through: :cocktails

  has_many :likes, foreign_key: 'liker_id', dependent: :destroy
  has_many :liked_cocktails, through: :likes, class_name: 'Cocktail'

  has_many :workplaces, foreign_key: 'bartender_id', dependent: :destroy
  has_many :bars, through: :workplaces

  has_many :favorites, dependent: :destroy
  has_many :favorited_bars, through: :favorites, class_name: 'Bar'

  # users that I follow
  has_many :following_users, foreign_key: :followee_id, class_name: 'Follow', dependent: :destroy
  has_many :followees, through: :following_users

  # users that follow me
  has_many :followed_users, foreign_key: :follower_id, class_name: 'Follow', dependent: :destroy
  has_many :followers, through: :followed_users

  has_secure_password
  validates :username, uniqueness: { case_sensitive: false }, presence: true

  # concern for image attachment
  include ImageAttachable
  has_one_attached :image
end

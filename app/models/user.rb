class User < ApplicationRecord
    has_many :cocktails, dependent: :destroy
    has_many :categories, through: :cocktails

    has_many :likes, dependent: :destroy
    has_many :liked_cocktails, through: :likes, class_name: 'Cocktail'

    has_many :followed_users, foreign_key: :follower_id, class_name: 'Follow', dependent: :destroy
    has_many :followees, through: :followed_users

    has_many :following_users, foreign_key: :followee_id, class_name: 'Follow', dependent: :destroy
    has_many :followers, through: :following_users

    has_secure_password
    validates :username, uniqueness: { case_sensitive: false }


end

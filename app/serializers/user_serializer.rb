class UserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :username, :location, :bartender, :work_at, :instagram_account, :followed_users, :following_users, :biography, :insta_follower, :insta_following, :profile_pic, :workplace_photos, :workplace_rating, :workplace_reviews, :workplace_ratings_total, :workplace_address
  has_many :cocktails
  has_many :likes
  has_many :followed_users
  has_many :following_users
end

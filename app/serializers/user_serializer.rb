class UserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :username, :location, :bartender, :work_at, :instagram_account, :profile_pic, :followed_users, :following_users, :biography, :insta_follower, :insta_following, :workplace
  # has_many :cocktails
  # has_many :likes
  has_many :followed_users
  has_many :following_users
end

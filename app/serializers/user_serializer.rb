class UserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :username, :location, :bartender, :instagram_account, :profile_pic, :biography, :insta_follower, :insta_following
  has_many :bars
  has_many :cocktails
  has_many :liked_cocktails
  has_many :followed_users
  has_many :following_users

end

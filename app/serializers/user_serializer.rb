class UserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :username, :password, :location, :bartender, :work_at, :instagram_account, :followed_users, :following_users
  has_many :likes
end

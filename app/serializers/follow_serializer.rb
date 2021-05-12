class FollowSerializer < ActiveModel::Serializer
  attributes :id, :follower, :followee
end

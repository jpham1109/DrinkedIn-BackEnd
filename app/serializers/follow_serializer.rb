class FollowSerializer < ActiveModel::Serializer
  attributes :id, :follower, :follower_id, :followee, :followee_id

end

class WorkplaceSerializer < ActiveModel::Serializer
  attributes :id, :bartender_id
  has_one :bar
end

class WorkplaceSerializer < ActiveModel::Serializer
  attributes :id, :bar
  # has_one :bar
end

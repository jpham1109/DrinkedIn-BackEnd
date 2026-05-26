# frozen_string_literal: true

class BarSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :website
end

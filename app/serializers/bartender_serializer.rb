# frozen_string_literal: true

class BartenderSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :username
end

# frozen_string_literal: true

class CategoryPreviewSerializer < ActiveModel::Serializer
  attributes :id, :name, :definition
end

class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :definition, :popular_drinks
  
end
class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :definition, :popular_drinks
  has_many :cocktails
  
end

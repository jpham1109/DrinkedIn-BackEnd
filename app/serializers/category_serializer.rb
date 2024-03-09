class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :definition, :popular_drinks
  has_many :cocktails
  # override the cocktails method to only return the ids of the cocktails
  class CocktailSerializer < ActiveModel::Serializer
    attributes :id
  end
end

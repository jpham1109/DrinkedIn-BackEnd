FactoryBot.define do
  factory :cocktail do
    sequence(:name) { |n| "Cocktail #{n}" }
    description { Faker::Lorem.sentence }
    execution { Faker::Lorem.sentence }
    ingredients { ['vodka', 'lime juice', 'soda water'] }
    association :bartender, factory: :user
    association :category
  end
end

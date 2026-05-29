FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    definition { Faker::Lorem.sentence }
  end
end

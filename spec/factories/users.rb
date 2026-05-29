FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    full_name { Faker::Name.name }
    password { 'password123' }
    location { Faker::Address.city }
    bartender { false }
  end
end

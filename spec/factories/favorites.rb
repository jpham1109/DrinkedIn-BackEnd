FactoryBot.define do
  factory :favorite do
    association :user
    association :favorited_bar, factory: :bar
  end
end

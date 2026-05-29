FactoryBot.define do
  factory :like do
    association :liker, factory: :user
    association :liked_cocktail, factory: :cocktail
  end
end

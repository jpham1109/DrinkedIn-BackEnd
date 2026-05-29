FactoryBot.define do
  factory :bar do
    sequence(:name) { |n| "Bar #{n}" }
  end
end

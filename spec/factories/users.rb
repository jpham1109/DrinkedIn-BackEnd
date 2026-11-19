FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    full_name { Faker::Name.name }
    password { 'password123' }
    location { Faker::Address.city }
    bartender { false }

    # ai/v1-redesign-plan.md's editorial-authorization workstream
    # (2026-11-18) — only accounts with editor: true may
    # create/update/destroy/publish/unpublish a cocktail.
    trait :editor do
      editor { true }
    end
  end
end

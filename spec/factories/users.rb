FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    # ai/v1-redesign-plan.md's email-signup-completion workstream
    # (2026-11-22) — User now requires email on: :create (app/models/user.rb),
    # so every create(:user)/build(:user).save across the suite needs a
    # valid, unique one by default. reserved `example.com` (RFC 2606) —
    # never a real, deliverable address.
    sequence(:email) { |n| "user#{n}@example.com" }
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

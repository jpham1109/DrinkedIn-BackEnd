FactoryBot.define do
  factory :cocktail do
    sequence(:name) { |n| "Cocktail #{n}" }
    description { Faker::Lorem.sentence }
    execution { Faker::Lorem.sentence }
    ingredients { ['vodka', 'lime juice', 'soda water'] }
    association :submitted_by, factory: :user
    association :category

    # ai/v1-redesign-plan.md's publication-lifecycle workstream
    # (2026-11-18) — a draft by default, matching the real model's own
    # default. Sets only published_at; doesn't also set creator_unknown,
    # since many call sites combine this with an explicit creator_user/
    # creator_name — setting both unconditionally would violate the
    # mutual-exclusivity validation. Add `creator_unknown: true`
    # explicitly wherever a test needs a published cocktail with no
    # other attribution.
    trait :published do
      published_at { Time.current }
    end
  end
end

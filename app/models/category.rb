# frozen_string_literal: true

class Category < ApplicationRecord
  # Case-insensitive, matching User#username's existing uniqueness
  # convention (app/models/user.rb) — "Tiki" and "tiki" are the same
  # editorial category, not two. Backed by a case-insensitive unique
  # index (db/migrate/*_add_unique_index_on_category_name.rb); this
  # validation gives a normal 422 instead of a raw Postgres constraint
  # violation, same pairing already used for the creator-attribution
  # check on Cocktail (ai/rules.md's "DB constraints, not only model
  # validations"). Confirmed zero duplicate names (exact or
  # case-insensitive) exist across all 19 real categories before adding
  # this — see ai/v1-redesign-plan.md's category audit.
  validates :name, uniqueness: { case_sensitive: false }

  has_many :cocktails
  # source: explicit since 2026-11-16 — Cocktail's own association was
  # renamed from :bartender to :submitted_by (ai/v1-redesign-plan.md's
  # creator/submitter attribution workstream, B1); without `source:`
  # here, Rails infers the through-association name from :bartenders
  # itself and would raise HasManyThroughSourceAssociationNotFoundError.
  # Not renamed to match (e.g. :submitters) in this PR — unused anywhere
  # in app/ or spec/ today (confirmed by grep), out of scope for a purely
  # mechanical rename; kept working as-is rather than touched further.
  has_many :bartenders, through: :cocktails, source: :submitted_by, class_name: 'User'
end

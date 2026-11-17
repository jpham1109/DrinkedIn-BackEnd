# frozen_string_literal: true

class Category < ApplicationRecord
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

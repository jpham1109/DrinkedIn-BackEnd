# frozen_string_literal: true

class BartenderSerializer < ActiveModel::Serializer
  # avatar/location added 2026-11-16 (ai/v1-redesign-plan.md's
  # creator/submitter attribution workstream, B3) — reused as-is for the
  # new `creator` association on CocktailSerializer below, so a
  # registered creator's name/avatar/location round-trip in the same
  # response as the cocktail, no second request needed. Additive to the
  # existing `bartender`/`submitted_by` nested objects too (new keys
  # only, nothing removed) — same `processed_image_url` method
  # UserSerializer already uses for its own `avatar`.
  attributes :id, :full_name, :username, :location, :avatar

  def avatar
    object.processed_image_url
  end
end

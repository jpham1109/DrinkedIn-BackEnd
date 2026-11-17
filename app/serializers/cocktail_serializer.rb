# frozen_string_literal: true

class CocktailSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  attributes :id, :name, :description, :ingredients, :execution, :photo, :bartender_id, :likes_count, :created_at,
             :submitted_by_id, :creator_user_id, :creator_name, :creator_unknown
  belongs_to :category, serializer: CategoryPreviewSerializer
  belongs_to :bartender, serializer: BartenderSerializer
  belongs_to :submitted_by, serializer: BartenderSerializer
  # Resolved registered-creator identity (name/avatar/location), nested
  # so the frontend's future PersonIdentity display never needs a
  # second request per cocktail to resolve `creator_user_id` — same
  # pattern `submitted_by` already uses. Null whenever creator_user_id
  # is unset (external name or unknown creator, or not yet decided);
  # frontend already has its own full user cache for anything this
  # doesn't cover.
  belongs_to :creator_user, serializer: BartenderSerializer, key: :creator

  def photo
    object.processed_image_url
  end

  # Legacy keys (ai/v1-redesign-plan.md's creator/submitter attribution
  # workstream, B3's "additive-then-remove" transition strategy) —
  # preserved byte-for-byte for existing frontend consumers until a
  # later, separate deploy removes them. Backed by the renamed
  # submitted_by/submitted_by_id association+column now (B1), not a real
  # `bartender` method on the model anymore.
  def bartender_id
    object.submitted_by_id
  end

  def bartender
    object.submitted_by
  end
end

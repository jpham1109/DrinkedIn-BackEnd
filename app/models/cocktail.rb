# frozen_string_literal: true

class Cocktail < ApplicationRecord
  # Renamed from :bartender 2026-11-16 (ai/v1-redesign-plan.md's
  # creator/submitter attribution workstream, B1) — this association has
  # always meant "who submitted/owns this record," never verified
  # authorship. See :creator_user/:creator_name/:creator_unknown below
  # for the independent authorship concept.
  belongs_to :submitted_by, class_name: 'User'
  class UserSerializer < ActiveModel::Serializer
    attributes :id, :full_name
  end

  belongs_to :category
  # inverse_of pairs this with User#created_cocktails — required
  # explicitly on both sides since the naming (creator_user_id vs.
  # created_cocktails) doesn't match Rails' automatic-inverse-detection
  # convention.
  belongs_to :creator_user, class_name: 'User', optional: true, inverse_of: :created_cocktails

  has_many :likes, foreign_key: 'liked_cocktail_id', dependent: :destroy
  has_many :likers, through: :likes, class_name: 'User'

  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18). Explicit, applied-where-needed scope — deliberately
  # not a default_scope, which would silently apply everywhere
  # (including editor contexts and internal fixture/rake-task queries)
  # and need `unscoped` sprinkled through anywhere a draft legitimately
  # needs to be visible.
  scope :published, -> { where.not(published_at: nil) }

  def published?
    published_at.present?
  end

  # Runs before the mutual-exclusivity check below AND before the DB
  # constraint sees the value, so a whitespace-only creator_name (e.g.
  # "   ") can never count as "set" at one layer but not the other —
  # without this, `creator_name: "   ", creator_unknown: true` would
  # pass the Ruby `.present?`-based validation (blank strings aren't
  # "present") but then fail the DB constraint's `IS NOT NULL` check
  # (whitespace isn't NULL), surfacing as a confusing raw
  # ActiveRecord::StatementInvalid instead of a normal validation error.
  # Also trims incidental leading/trailing whitespace from genuine names.
  before_validation :normalize_creator_name

  # Mirrors the DB check constraint added alongside creator_user_id/
  # creator_name/creator_unknown (B2) — kept as a model validation too,
  # per ai/rules.md's "use DB constraints for integrity (not only model
  # validations)", so API callers get a normal 422 with a readable
  # message instead of a raw Postgres constraint-violation error.
  validate :creator_attribution_mutually_exclusive

  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18). `if: -> { published_at.present? }`, not
  # `published_at_changed?` — these fire on *every* save that leaves the
  # record published, not only the initial draft→published transition,
  # so an editor can't silently strip required data from an
  # already-published cocktail without first unpublishing it (which
  # exempts both checks by construction, since published_at is nil at
  # that point). Drafts may be incomplete; nothing may stay published
  # without the minimum a reader needs to trust and recreate the drink.
  validate :creator_attribution_required_while_published, if: -> { published_at.present? }
  validate :recipe_complete_while_published, if: -> { published_at.present? }

  # concern for image attachment
  include ImageAttachable
  has_one_attached :image

  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18) — points at the gated delivery route
  # (CocktailsController#image), not a direct Active Storage URL. The
  # route itself decides whether to actually serve the image
  # (published? || current_user&.editor?) — generating this URL never
  # touches Active Storage at all, so there's nothing here that can
  # raise the way eager variant processing could.
  def processed_image_url
    return unless image.attached?

    Rails.application.routes.url_helpers.cocktail_image_url(id)
  end

  private

  def normalize_creator_name
    self.creator_name = creator_name.presence&.strip
  end

  def creator_attribution_mutually_exclusive
    set_count = [creator_user_id.present?, creator_name.present?, creator_unknown].count(true)
    return if set_count <= 1

    errors.add(:base,
               'Creator attribution must be exactly one of: a linked Kinpour user, an external name, ' \
               'or explicitly unknown — never more than one at a time.')
  end

  # The mutual-exclusivity check above caps attribution at one; this is
  # the complementary floor — at least one must be set for a cocktail to
  # be (or remain) published.
  def creator_attribution_required_while_published
    return if creator_user_id.present? || creator_name.present? || creator_unknown

    errors.add(:base,
               'A published cocktail must have an explicit creator attribution — a linked Kinpour ' \
               'user, an external name, or explicitly unknown.')
  end

  # docs/editorial-philosophy.md's "Reproducibility" criterion: the
  # published specification must allow the intended experience to be
  # recreated. Drafts may be missing any of this; a published (or
  # staying-published) cocktail may not.
  def recipe_complete_while_published
    errors.add(:name, "can't be blank") if name.blank?
    errors.add(:execution, "can't be blank") if execution.blank?
    errors.add(:ingredients, "can't be blank") if ingredients.blank?
    errors.add(:category_id, "can't be blank") if category_id.blank?
  end
end

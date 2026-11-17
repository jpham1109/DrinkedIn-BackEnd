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

  # concern for image attachment
  include ImageAttachable
  has_one_attached :image

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
end

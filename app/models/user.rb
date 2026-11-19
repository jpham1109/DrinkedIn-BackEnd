# frozen_string_literal: true

class User < ApplicationRecord
  # Flagged 2026-11-17 for the upcoming editorial-authorization/account-
  # deletion policy review — not changed in this PR. Deleting a
  # submitter/owner currently destroys their cocktails outright; once
  # publication exists, destroying a published cocktail out from under
  # readers (or an editor) by deleting an unrelated account may need its
  # own review, same as :created_cocktails below needed one.
  has_many :cocktails, foreign_key: 'submitted_by_id', dependent: :destroy
  has_many :categories, through: :cocktails

  # Independent from :cocktails above — a cocktail this user is credited
  # as the *creator* of, regardless of who submitted/owns the record
  # (ai/v1-redesign-plan.md's creator/submitter attribution workstream,
  # B1/B2). dependent: :restrict_with_error (changed from :nullify
  # 2026-11-17): silently clearing a verified creator credit on account
  # deletion conflicts with Kinpour's editorial-integrity goals,
  # especially once recipes can be published — for V1, deleting an
  # account blocks instead, until an authorized editor has explicitly
  # resolved its existing creator attributions. inverse_of pairs this
  # with Cocktail#creator_user below; naming doesn't follow Rails'
  # automatic-inverse-detection convention (creator_user_id vs.
  # created_cocktails), so it has to be explicit on both sides to
  # actually take effect.
  has_many :created_cocktails, class_name: 'Cocktail', foreign_key: 'creator_user_id',
                               dependent: :restrict_with_error, inverse_of: :creator_user

  has_many :likes, foreign_key: 'liker_id', dependent: :destroy
  has_many :liked_cocktails, through: :likes, class_name: 'Cocktail'

  has_many :workplaces, foreign_key: 'bartender_id', dependent: :destroy
  has_many :bars, through: :workplaces

  has_many :favorites, dependent: :destroy
  has_many :favorited_bars, through: :favorites, class_name: 'Bar'

  # users that I follow
  has_many :following_users, foreign_key: :followee_id, class_name: 'Follow', dependent: :destroy
  has_many :followees, through: :following_users

  # users that follow me
  has_many :followed_users, foreign_key: :follower_id, class_name: 'Follow', dependent: :destroy
  has_many :followers, through: :followed_users

  has_secure_password
  validates :username, uniqueness: { case_sensitive: false }, presence: true

  # concern for image attachment
  include ImageAttachable
  has_one_attached :image

  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18) — points at the gated delivery route
  # (UsersController#avatar). No draft concept applies to users; that
  # route's authorization is always-allow, same as before this change —
  # this is a working replacement for the route it's losing, not new
  # restriction.
  def processed_image_url
    return unless image.attached?

    Rails.application.routes.url_helpers.user_avatar_url(id)
  end
end

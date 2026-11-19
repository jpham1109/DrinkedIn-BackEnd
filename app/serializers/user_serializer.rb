# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :username, :location, :bartender, :avatar

  has_many :bars
  # override the bars method to only return the ids of the bars
  class BarSerializer < ActiveModel::Serializer
    attributes :id
  end

  has_many :cocktails
  # override the cocktails method to only return the ids of the cocktails
  class CocktailSerializer < ActiveModel::Serializer
    attributes :id
  end

  has_many :likes

  has_many :favorites
  # override the favorites method to only return the ids of the favorites
  class FavoriteSerializer < ActiveModel::Serializer
    attributes :id
  end

  has_many :followed_users

  has_many :following_users

  def avatar
    object.processed_image_url
  end

  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18) — same draft-concealment rule as CategorySerializer#cocktails:
  # current_user is available here for free when this serializer is
  # rendered through the normal controller `render json:` path (AMS's
  # controller integration auto-scopes it). Some call sites (e.g.
  # SessionsController#create, UsersController#signup) build
  # `UserSerializer.new(user)` directly with no scope at all — confirmed
  # via a real failing spec, not assumed — so `respond_to?(:current_user)`
  # guards against that case rather than raising; it fails closed
  # (treated as a non-editor view, drafts hidden) rather than exposing
  # drafts if scope is ever missing for any reason.
  #
  # Note: these re-query rather than filter the preloaded association
  # (UsersController#index's .includes(:cocktails, :likes)) for
  # non-editor requests — a known, accepted tradeoff for correct draft
  # concealment, not optimized further here (same category as the
  # existing, separately-flagged N+1 on cocktail images).
  def cocktails
    editor_viewing? ? object.cocktails : object.cocktails.published
  end

  def likes
    return object.likes if editor_viewing?

    object.likes.joins(:liked_cocktail).merge(Cocktail.published)
  end

  private

  def editor_viewing?
    respond_to?(:current_user) && current_user&.editor?
  end
end

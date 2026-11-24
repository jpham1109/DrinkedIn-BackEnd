# frozen_string_literal: true

module Users
  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18) — extracted from UsersController for the same reason as
  # Cocktails::ImagesController.
  #
  # Narrowed by the privacy-first-user-discovery workstream (2026-11-23),
  # Step 3: avatars were previously "always allowed, exactly as public
  # as the old (now-disabled) Active Storage route was" — confirmed live
  # that this let anyone enumerate every registered account's photo by
  # sequential id, including accounts with no public presence at all.
  # require_avatar_visible below is the narrowest fix that preserves
  # both legitimate uses: public creator attribution (must stay
  # reachable anonymously) and a creator viewing their own followers'
  # avatars in their Followers tab (Step 1/2's enriched identities).
  class AvatarsController < ApplicationController
    include ImageDelivery

    before_action :find_user
    before_action :require_avatar_visible

    # Standard app-defined variant; .send bypasses
    # ImageAttachable#image_variant's privacy, same pattern
    # ProcessImageVariantJob already uses.
    def show
      return deliver_image(nil) unless @user.image.attached?

      deliver_image(@user.send(:image_variant, @user.image).processed)
    end

    def original
      deliver_image(@user.image.attached? ? @user.image : nil)
    end

    private

    def find_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_not_found
    end

    # User.followable (Step 1's single source of truth, reused here
    # rather than redefined) — a public creator's avatar stays
    # anonymously fetchable, matching the public creator-attribution use
    # that must keep working for anonymous catalog visitors. Otherwise,
    # requires authentication and one of: viewing your own avatar,
    # being an editor, or viewing the avatar of an account that follows
    # *you* (the approved incoming-follow rule — the one legitimate
    # private-context case Step 1/2 introduced; the reverse direction,
    # current_user following the target, grants nothing extra once
    # FollowsController#create enforces User.followable, since every
    # followee is then already a public creator and already covered by
    # the branch above). Anyone else gets the same 404 a missing image
    # would — never a distinguishing response.
    def require_avatar_visible
      return if User.followable.exists?(id: @user.id)
      return if viewer_permitted?

      render_not_found
    end

    def viewer_permitted?
      return false unless current_user

      current_user.id == @user.id || current_user.editor? || Follow.exists?(follower: @user, followee: current_user)
    end

    def render_not_found
      response.headers['Cache-Control'] = 'private, no-store'
      render_error(code: 'not_found', message: 'Image not found.', status: :not_found)
    end
  end
end

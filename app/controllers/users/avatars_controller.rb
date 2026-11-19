# frozen_string_literal: true

module Users
  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18) — extracted from UsersController for the same reason as
  # Cocktails::ImagesController. No draft concept applies to users —
  # always allowed, exactly as public as the old (now-disabled) Active
  # Storage route was.
  class AvatarsController < ApplicationController
    include ImageDelivery

    before_action :find_user

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
    end
  end
end

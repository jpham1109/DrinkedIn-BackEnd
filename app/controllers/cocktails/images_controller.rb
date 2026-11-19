# frozen_string_literal: true

module Cocktails
  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18) — extracted from CocktailsController (which was pushing
  # past Metrics/ClassLength) since a cocktail's image delivery is a
  # distinct responsibility from its CRUD; Users::AvatarsController
  # follows the same split for user avatars.
  class ImagesController < ApplicationController
    include ImageDelivery
    include CocktailLookup

    before_action :find_cocktail
    before_action :require_published_or_editor

    # Standard app-defined variant (resize_to_limit: [500, 500], convert:
    # 'webp') — what's actually used today. .send bypasses
    # ImageAttachable#image_variant's privacy, same pattern
    # ProcessImageVariantJob already uses.
    def show
      return deliver_image(nil) unless @cocktail.image.attached?

      deliver_image(@cocktail.send(:image_variant, @cocktail.image).processed)
    end

    def original
      deliver_image(@cocktail.image.attached? ? @cocktail.image : nil)
    end
  end
end

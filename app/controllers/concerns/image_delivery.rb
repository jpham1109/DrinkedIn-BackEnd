# frozen_string_literal: true

# ai/v1-redesign-plan.md's publication-lifecycle workstream
# (2026-11-18). Shared by CocktailsController#image/#original_image and
# UsersController#avatar/#original_avatar — the only HTTP surfaces in
# the app that can ever produce a link to an attached image's actual
# bytes, now that the stock Active Storage engine routes are disabled
# (config.active_storage.draw_routes = false, config/application.rb).
#
# Verified against the installed activestorage 7.0.8 gem source before
# writing this (not assumed) — and re-verified live, after an initial
# read turned out to be wrong: this app sets config.load_defaults 6.1
# (config/application.rb), and railties' own
# lib/rails/application/configuration.rb unconditionally sets
# `active_storage.track_variants = true` as part of that load_defaults
# call — there is no visible `track_variants` line anywhere in this
# app's own config, which is what the first read missed. Confirmed live
# via `ActiveStorage.track_variants` → true. So the processed image is
# actually an ActiveStorage::VariantWithRecord, not plain
# ActiveStorage::Variant.
#
# VariantWithRecord delegates key/url/download to its own `.image`
# (itself a normal Attached::One, same delegation chain as any other
# attachment) — but does NOT delegate content_type at all. Blob and
# plain Variant both do. Hence asset_content_type below, rather than
# assuming one shared four-method interface across all three classes.
#
# ActiveStorage::Service::DiskService#url depends on the Active Storage
# engine's own mounted route (its generate_url calls
# url_helpers.rails_disk_service_url) — confirmed by reading
# disk_service.rb directly. Disabling draw_routes breaks that outright,
# unlike S3 (whose #url builds a presigned link against AWS directly,
# no Rails route involved). Disk therefore can't use the same
# redirect-based delivery S3 uses — it streams the bytes directly from
# this process instead, which has no route dependency at all.
module ImageDelivery
  extend ActiveSupport::Concern

  private

  # asset: nil (attachment not present), an ActiveStorage::Blob/
  # Attached::One (the original), or an ActiveStorage::VariantWithRecord
  # (the processed image, already called with #processed by the caller
  # so a cold/never-pre-warmed variant still resolves to a real file).
  #
  # Authorization must already have been checked by the caller before
  # this is ever invoked — this method only decides how to serve an
  # already-authorized asset, never whether to.
  def deliver_image(asset)
    response.headers['Cache-Control'] = 'private, no-store'

    if asset.nil?
      render_error(code: 'not_found', message: 'Image not found.', status: :not_found)
      return
    end

    if asset.service.is_a?(ActiveStorage::Service::DiskService)
      send_data asset.download, type: asset_content_type(asset), disposition: 'inline'
    else
      redirect_to asset.url(expires_in: 5.minutes, disposition: 'inline'), allow_other_host: true
    end
  end

  def asset_content_type(asset)
    asset.respond_to?(:content_type) ? asset.content_type : asset.image.content_type
  end
end

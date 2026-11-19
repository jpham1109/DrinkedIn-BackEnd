# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DrinkedInBackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.active_support.cache_format_version = 6.1
    config.action_mailer.default_url_options = { host: 'http://localhost:3010' }

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # ai/v1-redesign-plan.md's publication-lifecycle workstream
    # (2026-11-18). Every Active Storage controller is "publicly
    # accessible by default... hard to guess, but permanent by design"
    # (the engine's own doc comment) — there is no way to gate a draft
    # cocktail's image while these stock routes
    # (/rails/active_storage/blobs/*, /representations/*) stay mounted,
    # since they serve any valid signed id regardless of how it was
    # obtained. Disabling them entirely is what actually closes that —
    # see app/controllers/concerns/image_delivery.rb and
    # Cocktails::ImagesController/Users::AvatarsController for the only
    # replacement routes that exist now.
    config.active_storage.draw_routes = false

    # Found by a real failing test, not a source read: ActiveStorage::Blob#url
    # forces disposition: :attachment (silently overriding whatever
    # `disposition:` is passed in) unless the blob's content type is
    # explicitly allowlisted here — `content_types_allowed_inline`
    # defaults to `[]`, so every image would have downloaded instead of
    # displaying inline through the S3/redirect delivery branch
    # (ImageDelivery), even though the Disk branch's `send_data` call
    # was never affected (it doesn't go through Blob#url's
    # disposition-forcing logic at all). Must list every content type
    # ImageAttachable::ALLOWED_CONTENT_TYPES accepts on upload, plus
    # 'image/webp' for the processed variant's own output format
    # (already included — uploads already allow webp).
    config.active_storage.content_types_allowed_inline = %w[image/jpeg image/png image/webp]

    # Session/cookie middleware, added back manually per the comment above.
    # Required for the web session-cookie auth path added in the auth
    # migration (see ai/auth-migration-plan.md) — bearer JWT remains the
    # only path that works without this, this makes session-based auth
    # possible without disabling api_only.
    #
    # same_site: :lax worked everywhere this ran locally because
    # localhost:3030 (frontend) and localhost:3010 (backend) are
    # same-site to each other — "site" is scheme + registrable domain,
    # port doesn't count, so both are just "localhost". On Render the
    # frontend (Static Site) and backend (Web Service) are two different
    # registrable domains (*.onrender.com subdomains are same eTLD+1 but
    # distinct hosts — still genuinely cross-site for cookie purposes), so
    # a Lax cookie is simply never sent on the frontend's cross-origin
    # fetch/XHR requests there — login would silently never persist.
    # SameSite=None requires Secure, which `secure: Rails.env.production?`
    # already guarantees.
    config.session_store :cookie_store,
                         key: '_drinkedin_session',
                         same_site: Rails.env.production? ? :none : :lax,
                         httponly: true,
                         secure: Rails.env.production?
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use config.session_store, config.session_options
  end
end

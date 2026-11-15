# frozen_string_literal: true

# Render's healthCheckPath (render.yaml) — gates traffic routing to a
# newly-deployed instance until this returns 2xx. Checks DB connectivity
# specifically because a broken DATABASE_URL (wrong credentials, DB not
# yet provisioned) would otherwise still 200 here while every real
# request 500s — the one failure mode a bare "process is up" check can't
# catch. Unauthenticated, GET-only, not CSRF-protected (same as
# CsrfTokensController) — Render's health checker carries no session.
class HealthController < ApplicationController
  def show
    ActiveRecord::Base.connection.execute('SELECT 1')
    render_success({ status: 'ok' })
  rescue StandardError => e
    Rails.logger.error "Health check failed: #{e.message}"
    render_error(code: 'service_unavailable', message: 'Service unavailable', status: :service_unavailable)
  end
end

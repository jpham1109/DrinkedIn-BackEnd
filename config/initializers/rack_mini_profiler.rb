# frozen_string_literal: true

require 'rack-mini-profiler'
# Enable Rack::MiniProfiler in development. Visit `/_mini-profiler-resources/includes` to view your performance metrics.
if Rails.env.development?
  # configures the Rack::MiniProfiler to start in hidden mode, where it won't attempt to inject its UI to non-existent HTML responses (as in API-only applications)
  Rack::MiniProfiler.config.start_hidden = true
  # explicitly requires the initialization of the middleware in case the auto-initialization by Bundler and Rails doesnt work as expected (might not needed)
  Rack::MiniProfilerRails.initialize!(Rails.application)
end

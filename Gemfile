# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
# gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.0'

# uncomment to fix gem dependencies issues from upgrading ruby and rails versions
gem 'net-http'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.5', '>= 1.5.6'
# measures the performance metrics
gem 'memory_profiler'
gem 'rack-mini-profiler', require: false
# Use Puma as the app server
gem 'puma', '~> 6.4', '>= 6.4.2'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
gem 'image_processing', '~> 1.2'
# for lipvips
gem 'ruby-vips', '~> 2.0', '>= 2.0.17'
# library and registry for information about MIME content type definitions
gem 'mime-types'
# detect security vulnerabilities in Rails application via static analysis
gem 'brakeman', '~> 3.3', '>= 3.3.2'

# static code analyzer and formatter for Ruby
gem 'rubocop', '~> 1.62', '>= 1.62.1', require: false
# an extension of RuboCop, focusing on Ruby on Rails-specific best practices and conventions
gem 'rubocop-rails', require: false

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
# wrapper for ImageMagick for image processing
gem 'mini_magick'

gem 'active_model_serializers'
gem 'activerecord-reset-pk-sequence'
gem 'active_storage_validations'
gem 'awesome_print'
# pure ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT) standard
gem 'dotenv-rails', groups: %i[development test]
gem 'faraday'
gem 'jwt', '~> 2.8', '>= 2.8.1'

# allows bulk insert of data into database
gem 'activerecord-import'
# a testing framework for Rails
gem 'rspec'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'debug', '~> 1.9', '>= 1.9.2'
  gem 'rspec-rails', '~> 5.0.0'
end

group :development do
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # help increase performance by reducing the number of queries it makes
  gem 'bullet', '~> 7.1', '>= 7.1.6'

  gem 'error_highlight', '~> 0.6.0', platforms: [:ruby]
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

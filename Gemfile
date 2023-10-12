source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
# gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.0'
#uncomment to fix gem dependencies issues from upgrading ruby and rails versions
gem "net-http"
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
gem 'rack-mini-profiler'
gem 'memory_profiler'
# Use Puma as the app server
gem 'puma', '~> 6.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

gem "mini_magick"
gem 'activerecord-reset-pk-sequence'
gem 'active_model_serializers'
gem 'active_storage_validations'
gem 'awesome_print'
gem "jwt", "~> 2.2"
gem 'faraday'
gem 'dotenv-rails', :groups => [:development, :test]

#gem Bullet specs for rails 7
gem 'sqlite3'
gem 'activerecord-jdbcsqlite3-adapter', platforms: [:jruby]
gem 'activerecord-import'

gem "rspec"



group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "debug", ">= 1.5"
end

group :development do
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  #help increase performance by reducing the number of queries it makes
  gem 'bullet'

  gem "error_highlight", ">= 0.4.0", platforms: [:ruby]
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Make sure it matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.0
FROM ruby:3.3.0-slim

# Install libvips for Active Storage preview support and PostgreSQL development headers
RUN apt-get update -qq && \
    apt-get install -y build-essential libvips bash bash-completion libffi-dev tzdata postgresql libpq-dev nodejs npm yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man
# Rails app lives here
WORKDIR /rails

# Set production environment
# ENV RAILS_LOG_TO_STDOUT="1" \
#     RAILS_SERVE_STATIC_FILES="true" \
#     RAILS_ENV="production" \
#     BUNDLE_WITHOUT="development"

# Install application gems
COPY Gemfile* .
# configure bundler to use the Ruby platform to address gem installation issues, such as native extensions
RUN bundle config set --local force_ruby_platform true
# Install gems
RUN bundle install

#Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile --gemfile app/ lib/

#Change permissions for entrypoint
RUN chmod +x /rails/bin/docker-entrypoint

# Add a script to be executed every time the container starts.
# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
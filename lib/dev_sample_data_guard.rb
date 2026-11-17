# frozen_string_literal: true

# Safety guard for lib/tasks/dev_sample_data.rake's destructive reset.
# Extracted into a plain, dependency-injected class — not inlined in the
# rake task — specifically so each check can be unit-tested in isolation
# without invoking Rake::Task machinery at all (see
# spec/lib/dev_sample_data_guard_spec.rb).
#
# Four independent checks, in this exact order, none skippable:
#   1. Rails.env must be 'development'.
#   2. The *resolved* connection config (database/host/port) must match
#      an explicit allowlist — not assumed from an env var or "intended"
#      configuration.
#   3. The *live* Postgres connection's own reported server port
#      (inet_server_port(), straight from the wire protocol) must also
#      match — independent of whatever the config says. This is
#      specifically the check that would have caught the 2026-11-16
#      incident: a config/env-var-only check would have been fooled the
#      same way the original mistake was, since the override *looked*
#      like it redirected the connection but silently didn't.
#   4. An explicit CONFIRM_RESET=yes flag.
#
# `check!` raises on the first failing check and never returns normally
# unless all four pass — callers must not run any destructive statement
# before it returns.
class DevSampleDataGuard
  AUTHORIZED_DATABASE = 'DrinkedIn_BackEnd_development'
  AUTHORIZED_HOSTS = %w[db localhost 127.0.0.1].freeze
  AUTHORIZED_PORT = 5432

  GuardError = Class.new(StandardError)

  def initialize(connection: ActiveRecord::Base.connection, env: Rails.env,
                 confirm_flag: ENV.fetch('CONFIRM_RESET', nil))
    @connection = connection
    @env = env
    @confirm_flag = confirm_flag
  end

  def check!
    check_environment!
    check_resolved_connection!
    check_live_server_endpoint!
    check_confirmation!
    true
  end

  private

  attr_reader :connection, :env, :confirm_flag

  def check_environment!
    return if env.to_s == 'development'

    raise GuardError, "Refusing: Rails.env is '#{env}', not 'development'."
  end

  def resolved_config
    connection.pool.db_config.configuration_hash
  end

  def check_resolved_connection!
    config = resolved_config
    database = config[:database]
    host = config[:host]
    port = config[:port] || AUTHORIZED_PORT

    unless database == AUTHORIZED_DATABASE
      raise GuardError,
            "Refusing: resolved database is '#{database}', expected '#{AUTHORIZED_DATABASE}'. " \
            'This guard exists specifically because an env var override once looked like it ' \
            'redirected the connection but silently did not — never trust the override alone.'
    end

    unless AUTHORIZED_HOSTS.include?(host)
      raise GuardError, "Refusing: resolved host is '#{host}', expected one of #{AUTHORIZED_HOSTS.inspect}."
    end

    return if port == AUTHORIZED_PORT

    raise GuardError, "Refusing: resolved port is '#{port}', expected #{AUTHORIZED_PORT}."
  end

  def check_live_server_endpoint!
    live_port = connection.select_value('SELECT inet_server_port()')
    return if live_port.nil? # Unix-socket connections report no TCP port; the config check above still applies.
    return if live_port.to_i == AUTHORIZED_PORT

    raise GuardError, "Refusing: live server port is '#{live_port}', expected #{AUTHORIZED_PORT}."
  end

  def check_confirmation!
    return if confirm_flag == 'yes'

    raise GuardError, 'Refusing: re-run with CONFIRM_RESET=yes to proceed.'
  end
end

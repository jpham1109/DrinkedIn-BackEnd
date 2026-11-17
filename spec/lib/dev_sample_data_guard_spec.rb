# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('lib/dev_sample_data_guard')

# Isolated unit tests — no Rake::Task invocation, no real database
# write. Every check is exercised via a plain double standing in for
# the ActiveRecord connection, injected through the constructor.
RSpec.describe DevSampleDataGuard do
  let(:authorized_config) { { database: 'DrinkedIn_BackEnd_development', host: 'db', port: nil } }

  def connection_double(config: authorized_config, live_port: 5432)
    db_config = double('db_config', configuration_hash: config)
    pool = double('pool', db_config:)
    double('connection', pool:, select_value: live_port)
  end

  def guard(env: 'development', confirm_flag: 'yes', connection: connection_double)
    described_class.new(connection:, env:, confirm_flag:)
  end

  it 'passes when environment, resolved connection, live endpoint, and confirmation all match' do
    expect(guard.check!).to be true
  end

  describe 'environment check' do
    it 'raises when Rails.env is not development' do
      expect { guard(env: 'test').check! }
        .to raise_error(described_class::GuardError, /Rails\.env is 'test', not 'development'/)
    end

    it 'checks environment before the connection is ever consulted' do
      # A connection double with no stubbed methods would raise NoMethodError
      # if check! tried to read it — proving the environment check runs
      # first and short-circuits before touching the connection at all.
      unusable_connection = Object.new
      expect { guard(env: 'test', connection: unusable_connection).check! }
        .to raise_error(described_class::GuardError, /Rails\.env/)
    end
  end

  describe 'resolved connection check (database/host/port allowlist)' do
    it 'raises when the resolved database name does not match' do
      connection = connection_double(config: authorized_config.merge(database: 'some_other_db'))
      expect { guard(connection:).check! }
        .to raise_error(described_class::GuardError, /resolved database is 'some_other_db'/)
    end

    it 'raises when the resolved host is not on the allowlist' do
      connection = connection_double(config: authorized_config.merge(host: 'some-random-host.example.com'))
      expect { guard(connection:).check! }
        .to raise_error(described_class::GuardError, /resolved host is 'some-random-host\.example\.com'/)
    end

    it 'raises when the resolved port is explicitly set to something unexpected' do
      connection = connection_double(config: authorized_config.merge(port: 9999))
      expect { guard(connection:).check! }
        .to raise_error(described_class::GuardError, /resolved port is '9999'/)
    end

    it 'treats a missing port in the resolved config as the authorized default (5432)' do
      connection = connection_double(config: authorized_config.merge(port: nil))
      expect(guard(connection:).check!).to be true
    end
  end

  describe 'live server endpoint check' do
    it 'raises when the live server port does not match, independent of the config check passing' do
      connection = connection_double(live_port: 9999)
      expect { guard(connection:).check! }
        .to raise_error(described_class::GuardError, /live server port is '9999'/)
    end

    it 'does not raise when the live connection reports no TCP port (e.g. a Unix socket)' do
      connection = connection_double(live_port: nil)
      expect(guard(connection:).check!).to be true
    end
  end

  describe 'confirmation check' do
    it 'raises when CONFIRM_RESET is missing' do
      expect { guard(confirm_flag: nil).check! }
        .to raise_error(described_class::GuardError, /CONFIRM_RESET=yes/)
    end

    it 'raises when CONFIRM_RESET is present but not exactly "yes"' do
      expect { guard(confirm_flag: 'true').check! }
        .to raise_error(described_class::GuardError, /CONFIRM_RESET=yes/)
    end

    it 'checks confirmation last — a wrong database AND a missing confirmation both fail, ' \
       'but the connection error is the one raised' do
      connection = connection_double(config: authorized_config.merge(database: 'wrong_db'))
      expect { guard(connection:, confirm_flag: nil).check! }
        .to raise_error(described_class::GuardError, /resolved database is 'wrong_db'/)
    end
  end
end

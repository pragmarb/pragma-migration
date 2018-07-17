# frozen_string_literal: true

RSpec.describe Pragma::Migration::Hooks::Operation do
  subject(:result) do
    operation_klass.call(
      {},
      {
        'rack.request' => Rack::Request.new('X-Test-Api-Version' => api_version)
      }
    )
  end

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    module API
      module Migration
        class SendNewsletterAutomatically < Pragma::Migration::Base
        end
      end

      class MigrationRepository < Pragma::Migration::Repository
        version '2018-07-15'

        version '2018-07-16', [
          API::Migration::SendNewsletterAutomatically
        ]
      end
    end

    Pragma::Migration.repository = API::MigrationRepository

    Pragma::Migration.user_version_proc = lambda do |request|
      request.get_header 'X-Test-Api-Version'
    end
  end

  let(:api_version) { '2018-07-15' }

  let(:operation_klass) do
    Class.new(Pragma::Operation::Base) do
      success :check_migrations!

      def check_migrations!(options, **)
        options['result.migration_rolled'] = migration_rolled?(
          options,
          API::Migration::SendNewsletterAutomatically
        )

        options['result.migration_pending'] = migration_pending?(
          options,
          API::Migration::SendNewsletterAutomatically
        )

        options['result.migration_applies'] = migration_applies?(
          options,
          API::Migration::SendNewsletterAutomatically
        )

        options['result.rolled_migrations'] = rolled_migrations(options)

        options['result.applying_migrations'] = applying_migrations(options)

        options['result.pending_migrations'] = pending_migrations(options)
      end
    end
  end

  describe '#migration_rolled?' do
    it 'returns whether the migration was rolled' do
      expect(result['result.migration_rolled']).to eq(false)
    end
  end

  describe '#migration_pending?' do
    it 'returns whether the migration is pending' do
      expect(result['result.migration_pending']).to eq(true)
    end
  end

  describe '#migration_applies?' do
    it 'returns whether the migration applies' do
      expect(result['result.migration_applies']).to eq(false)
    end
  end

  describe '#rolled_migrations' do
    it 'returns all rolled migrations' do
      expect(result['result.rolled_migrations']).to eq([])
    end
  end

  describe '#applying_migrations' do
    it 'returns all applying migrations' do
      expect(result['result.applying_migrations']).to eq([])
    end
  end

  describe '#pending_migrations' do
    it 'returns all pending migrations' do
      expect(result['result.pending_migrations']).to eq([
        API::Migration::SendNewsletterAutomatically
      ])
    end
  end
end

# frozen_string_literal: true

RSpec.describe Pragma::Migration::Repository do
  subject(:repository) { Class.new(described_class) }

  describe '.version' do
    it 'adds a version' do
      repository.instance_eval do
        version '2017-12-27'
      end

      expect(repository.sorted_versions).to match([instance_of(Pragma::Migration::Version)])
    end

    it 'keeps versions sorted' do
      repository.instance_eval do
        version '2017-12-28'
        version '2017-12-27'
      end

      expect(repository.sorted_versions.map(&:number)).to eq(['2017-12-27', '2017-12-28'])
    end

    it 'initializes migrations' do
      migration = Class.new(Pragma::Migration::Base)
      repository.send :version, '2017-12-28', [migration]
      expect(repository.sorted_versions.first.migrations).to eq([migration])
    end
  end

  describe '.migrations_since' do
    let(:migration1) { Class.new(Pragma::Migration::Base) }
    let(:migration2) { Class.new(Pragma::Migration::Base) }
    let(:migration3) { Class.new(Pragma::Migration::Base) }

    before do
      repository.send :version, '2017-12-24'
      repository.send :version, '2017-12-25', [migration1]
      repository.send :version, '2017-12-26', [migration2]
      repository.send :version, '2017-12-27', [migration3]
    end

    it 'collects all the changes since the specified version' do
      expect(repository.migrations_since('2017-12-25')).to eq([migration2, migration3])
    end
  end

  describe '.migration_active?' do
    let(:migration1) { Class.new(Pragma::Migration::Base) }
    let(:migration2) { Class.new(Pragma::Migration::Base) }

    before do
      repository.send :version, '2017-12-24'
      repository.send :version, '2017-12-25', [migration1]
      repository.send :version, '2017-12-26', [migration2]
    end

    it 'returns false when the migration is not active' do
      expect(repository.migration_active?(migration1, user_version: '2017-12-25')).to eq(false)
    end

    it 'returns true when the migration is active' do
      expect(repository.migration_active?(migration2, user_version: '2017-12-25')).to eq(true)
    end
  end

  describe '.migrations_for' do
    let(:migration1) do
      Class.new(Pragma::Migration::Base) do
        apply_to '/api/v1/articles/*'
      end
    end

    let(:migration2) do
      Class.new(Pragma::Migration::Base) do
        apply_to '/api/v1/articles/*'
      end
    end

    let(:migration3) do
      Class.new(Pragma::Migration::Base) do
        apply_to '/api/v1/posts/*'
      end
    end

    before do
      repository.send :version, '2017-12-24'
      repository.send :version, '2017-12-25', [migration1]
      repository.send :version, '2017-12-26', [migration2]
      repository.send :version, '2017-12-27', [migration3]
    end

    it 'returns the migrations applying to the current request' do
      expect(repository.migrations_for(Rack::Request.new(
        'PATH_INFO' => '/api/v1/articles/1',
        'X-Api-Version' => '2017-12-25'
      ))).to eq([migration2])
    end
  end
end

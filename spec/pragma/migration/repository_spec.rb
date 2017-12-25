# frozen_string_literal: true

RSpec.describe Pragma::Migration::Repository do
  subject(:repository) { Class.new(described_class) }

  describe '.version' do
    it 'adds a version' do
      repository.version '2017-12-27'
      expect(repository.sorted_versions).to match([instance_of(Pragma::Migration::Version)])
    end

    it 'keeps versions sorted' do
      repository.version '2017-12-28'
      repository.version '2017-12-27'
      expect(repository.sorted_versions.map(&:number)).to eq(['2017-12-27', '2017-12-28'])
    end

    it 'initializes migrations' do
      migration = Class.new(Pragma::Migration::Base)
      repository.version '2017-12-28', [migration]
      expect(repository.sorted_versions.first.migrations).to eq([migration])
    end
  end

  describe '.migrations_since' do
    let(:migration1) { Class.new(Pragma::Migration::Base) }
    let(:migration2) { Class.new(Pragma::Migration::Base) }
    let(:migration3) { Class.new(Pragma::Migration::Base) }

    before do
      repository.version '2017-12-24'
      repository.version '2017-12-25', [migration1]
      repository.version '2017-12-26', [migration2]
      repository.version '2017-12-27', [migration3]
    end

    it 'collects all the changes since the specified version' do
      expect(repository.migrations_since('2017-12-25')).to eq([migration2, migration3])
    end
  end

  describe '.migration_active?' do
    let(:migration1) { Class.new(Pragma::Migration::Base) }
    let(:migration2) { Class.new(Pragma::Migration::Base) }
    let(:migration3) { Class.new(Pragma::Migration::Base) }

    before do
      repository.version '2017-12-24'
      repository.version '2017-12-25', [migration1]
      repository.version '2017-12-26', [migration2]
      repository.version '2017-12-27', [migration3]
    end

    it 'returns false when the migration is not active' do
      expect(repository.migration_active?('2017-12-25', migration1)).to eq(false)
    end

    it 'returns true when the migration is active' do
      expect(repository.migration_active?('2017-12-25', migration2)).to eq(true)
    end
  end
end

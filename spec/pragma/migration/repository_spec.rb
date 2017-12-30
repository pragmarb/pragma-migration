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
end

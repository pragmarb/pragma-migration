# frozen_string_literal: true

RSpec.describe Pragma::Migration::Base do
  subject(:migration_klass) do
    Class.new(described_class)
  end

  describe '.apply_to' do
    before { subject.apply_to('test_pattern') }

    it 'sets the pattern' do
      expect(migration_klass.pattern).to eq('test_pattern')
    end
  end

  describe '.describe' do
    before { subject.describe('test_description') }

    it 'sets the description' do
      expect(migration_klass.description).to eq('test_description')
    end
  end
end

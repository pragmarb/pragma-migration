# frozen_string_literal: true

RSpec.describe Pragma::Migration::Base do
  subject(:migration_klass) do
    Class.new(described_class) do
      apply_to '/api/v1/articles/*'
      describe 'Test migration'
    end
  end

  describe '.apply_to' do
    it 'sets the pattern' do
      expect(migration_klass.pattern).to eq('/api/v1/articles/*')
    end
  end

  describe '.describe' do
    it 'sets the description' do
      expect(migration_klass.description).to eq('Test migration')
    end
  end

  describe '.applies_to?' do
    it 'returns true when the pattern applies to a path' do
      expect(migration_klass).to be_applies_to(
        Rack::Request.new('PATH_INFO' => '/api/v1/articles/1')
      )
    end

    it 'returns false when the pattern does not apply to a path' do
      expect(migration_klass).not_to be_applies_to(
        Rack::Request.new('PATH_INFO' => '/api/v1/posts/1')
      )
    end
  end
end

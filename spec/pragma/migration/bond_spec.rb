# frozen_string_literal: true

RSpec.describe Pragma::Migration::Bond do
  subject do
    described_class.new(
      repository: repository,
      request: request,
      user_version: '2017-12-25'
    )
  end

  let(:migration1) { Class.new(Pragma::Migration::Base) }
  let(:migration2) do
    Class.new(Pragma::Migration::Base) do
      apply_to '/api/v1/articles/*'
    end
  end
  let(:migration3) { Class.new(Pragma::Migration::Base) }

  let(:repository) do
    Class.new(Pragma::Migration::Repository).tap do |repo|
      repo.send :version, '2017-12-24'
      repo.send :version, '2017-12-25', [migration1]
      repo.send :version, '2017-12-26', [migration2]
      repo.send :version, '2017-12-27', [migration3]
    end
  end

  let(:request) do
    Rack::Request.new(Rack::MockRequest.env_for('/api/v1/articles/1', method: :patch).merge(
      'X-Api-Version' => '2017-12-25'
    ))
  end

  describe '.pending_migrations' do
    it 'returns the migrations that must be executed' do
      expect(subject.pending_migrations).to eq([migration2, migration3])
    end
  end

  describe '.rolled_migrations' do
    it 'returns the migrations that have been executed' do
      expect(subject.rolled_migrations).to eq([migration1])
    end
  end

  describe '.applying_migrations' do
    it 'returns the pending migrations that apply to this request' do
      expect(subject.applying_migrations).to eq([migration2])
    end
  end
end

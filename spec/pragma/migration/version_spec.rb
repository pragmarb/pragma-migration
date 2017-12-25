# frozen_string_literal: true

RSpec.describe Pragma::Migration::Version do
  subject { described_class.new('2017-12-28') }

  it 'sets the version number' do
    expect(subject.number).to eq('2017-12-28')
  end

  it 'initializes the migrations' do
    expect(subject.migrations).to eq([])
  end

  describe '#<=>' do
    let(:a) { described_class.new('2017-12-10') }
    let(:b) { described_class.new('2018-01-09') }
    let(:c) { described_class.new('2018-02-09') }

    # rubocop:disable Lint/UselessComparison
    it 'sorts properly' do
      expect([
        a.<=>(a),
        a.<=>(b),
        a.<=>(c),
        b.<=>(a),
        b.<=>(b),
        b.<=>(c),
        c.<=>(a),
        c.<=>(b),
        c.<=>(c)
      ]).to eq([
        0,
        -1,
        -1,
        1,
        0,
        -1,
        1,
        1,
        0
      ])
    end
    # rubocop:enable Lint/UselessComparison
  end

  describe '#migration?' do
    let(:migration) { Class.new(Pragma::Migration::Base) }

    it 'returns true when the version contains the migration' do
      subject.migrations << migration
      expect(subject.migration?(migration)).to eq(true)
    end

    it 'returns false when the version does not contain the migration' do
      expect(subject.migration?(migration)).to eq(false)
    end
  end
end

# frozen_string_literal: true

RSpec.describe Pragma::Migration do
  describe '.config' do
    it 'returns a configuration object' do
      expect(subject.config).to be_instance_of(Pragma::Migration::Configuration)
    end
  end

  describe '.configure' do
    it 'yields the comfiguration' do
      expect { |b| subject.configure(&b) }.to yield_with_args(
        an_instance_of(Pragma::Migration::Configuration)
      )
    end
  end
end

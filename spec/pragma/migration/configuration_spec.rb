# frozen_string_literal: true

RSpec.describe Pragma::Migration::Configuration do
  subject { described_class.new }

  describe '#user_version_proc' do
    it 'provides a default' do
      expect(subject.user_version_proc).not_to be_nil
    end
  end

  describe '#user_version_proc=' do
    it 'overrides the default proc' do
      custom_proc = -> { true }

      expect {
        subject.user_version_proc = custom_proc
      }.to change(subject, :user_version_proc).to(custom_proc)
    end
  end
end

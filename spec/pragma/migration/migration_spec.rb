# frozen_string_literal: true

RSpec.describe Pragma::Migration do
  describe '#repository=' do
    it 'changes the repository' do
      expect {
        subject.repository = 'test'
      }.to change(subject, :repository).to('test')
    end
  end
end

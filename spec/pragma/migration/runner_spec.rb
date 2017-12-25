# frozen_string_literal: true

RSpec.describe Pragma::Migration::Runner do
  subject { described_class.new(repository: repository, user_version: user_version) }

  let(:repository) do
    Class.new(Pragma::Migration::Repository) do
      remove_author_name = Class.new(Pragma::Migration::Base) do
        def up(request)
          request.delete(:author_name)
        end

        def down(response)
          response.merge(author_name: 'John')
        end
      end

      rename_author_to_author_id = Class.new(Pragma::Migration::Base) do
        def up(request)
          request.merge(author: request.delete(:author_id))
        end

        def down(response)
          response.merge(author_id: response.delete(:author))
        end
      end

      convert_published_at_into_unix_epoch = Class.new(Pragma::Migration::Base) do
        def up(request)
          request.merge(published_at: Time.new(request[:published_at]).to_i)
        end

        def down(response)
          response.merge(published_at: Time.at(response[:published_at]).to_s)
        end
      end

      version '2017-12-24'

      version '2017-12-25', [
        # This one will not be applied because it's the user's current version.
        remove_author_name
      ]

      version '2017-12-26', [
        rename_author_to_author_id
      ]

      version '2017-12-27', [
        convert_published_at_into_unix_epoch
      ]
    end
  end

  let(:user_version) { '2017-12-25' }

  describe '#run_upwards' do
    let(:time) { Time.new('2014-11-06T10:40:54+11:00') }

    let(:request) do
      {
        author_id: 'test_id',
        published_at: time.to_s
      }
    end

    it 'applies the migrations to the request' do
      expect(subject.run_upwards(request)).to eq(
        author: 'test_id',
        published_at: time.to_i
      )
    end
  end

  describe '#run_downwards' do
    let(:time) { Time.new('2014-11-06T10:40:54+11:00') }

    let(:response) do
      {
        author: 'test_id',
        published_at: time.to_i
      }
    end

    it 'applies the migrations to the response' do
      expect(subject.run_downwards(response)).to eq(
        published_at: time.to_s,
        author_id: 'test_id'
      )
    end
  end
end

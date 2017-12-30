# frozen_string_literal: true

RSpec.describe Pragma::Migration::Runner do
  subject { described_class.new(repository) }

  let(:repository) do
    Class.new(Pragma::Migration::Repository) do
      remove_author_name = Class.new(Pragma::Migration::Base) do
        apply_to '/api/v1/articles/:id'

        def up
          request.tap { |r| r.params.delete('author_name') }
        end

        def down
          parsed_body = JSON.parse(response.body)

          Rack::Response.new(
            JSON.dump(parsed_body.merge('author_name' => 'John')),
            response.status,
            response.headers
          )
        end
      end

      rename_author_to_author_id = Class.new(Pragma::Migration::Base) do
        apply_to '/api/v1/articles/:id'

        def up
          request.tap { |r| r.params['author'] = r.params.delete('author_id') }
        end

        def down
          parsed_body = JSON.parse(response.body.first)

          Rack::Response.new(
            JSON.dump(parsed_body.merge(
              'author_id' => parsed_body.delete('author')
            )),
            response.status,
            response.headers
          )
        end
      end

      convert_published_at_into_unix_epoch = Class.new(Pragma::Migration::Base) do
        apply_to '/api/v1/articles/:id'

        def up
          request.tap do |r|
            r.params['published_at'] = Time.new(request.params['published_at']).to_i
          end
        end

        def down
          parsed_body = JSON.parse(response.body.first)

          Rack::Response.new(
            JSON.dump(parsed_body.merge(
              'published_at' => Time.at(parsed_body['published_at']).to_s
            )),
            response.status,
            response.headers
          )
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
      Rack::Request.new(Rack::MockRequest.env_for('/api/v1/articles/1', method: :patch, params: {
        'author_id' => 'test_id',
        'published_at' => time.to_s
      }).merge('X-Api-Version' => '2017-12-25'))
    end

    it 'applies the migrations to the request' do
      expect(subject.run_upwards(request).params).to eq(
        'author' => 'test_id',
        'published_at' => time.to_i
      )
    end
  end

  describe '#run_downwards' do
    let(:time) { Time.new('2014-11-06T10:40:54+11:00') }

    let(:request) do
      Rack::Request.new(Rack::MockRequest.env_for('/api/v1/articles/1', method: :patch, params: {
        'author_id' => 'test_id',
        'published_at' => time.to_s
      }).merge('X-Api-Version' => '2017-12-25'))
    end

    let(:response) do
      Rack::Response.new(JSON.dump(
        author: 'test_id',
        published_at: time.to_i
      ))
    end

    it 'applies the migrations to the response' do
      expect(JSON.parse(subject.run_downwards(request, response).body.first)).to eq(
        'published_at' => time.to_s,
        'author_id' => 'test_id'
      )
    end
  end
end

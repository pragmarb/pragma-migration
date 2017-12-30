# frozen_string_literal: true

RSpec.describe Pragma::Migration::Middleware do
  subject { described_class.new(app, repository: repository) }

  let(:app) do
    Class.new do
      def self.call(env)
        [200, {}, JSON.dump(Rack::Request.new(env).params)]
      end
    end
  end

  let(:repository) do
    Class.new(Pragma::Migration::Repository) do
      determine_version_with do |request|
        request.get_header 'X-Test-Api-Version'
      end

      version '2017-12-25'
    end.tap do |repo|
      remove_id_from_author = Class.new(Pragma::Migration::Base) do
        apply_to '/api/v1/posts/*'

        def up
          request.update_param('author', request.delete_param('author_id'))
        end

        def down
          parsed_body = JSON.parse(response.body.join(''))
          Rack::Response.new(
            JSON.dump(parsed_body.merge('author_id' => parsed_body.delete('author'))),
            response.status,
            response.headers
          )
        end
      end

      remove_id_from_category = Class.new(Pragma::Migration::Base) do
        apply_to '/api/v1/posts/*'

        def up
          request.update_param('category', request.delete_param('category_id'))
        end

        def down
          parsed_body = JSON.parse(response.body.join(''))
          Rack::Response.new(
            JSON.dump(parsed_body.merge('category_id' => parsed_body.delete('category'))),
            response.status,
            response.headers
          )
        end
      end

      repo.send :version, '2017-12-26', [remove_id_from_author]
      repo.send :version, '2017-12-27', [remove_id_from_category]
    end
  end

  let(:env) do
    Rack::MockRequest.env_for('/api/v1/posts/1', method: :patch, params: {
      'author_id' => 'test_author_id',
      'category_id' => 'test_category_id'
    }).merge('X-Test-Api-Version' => '2017-12-25')
  end

  it 'applies migrations upwards to the request' do
    expect(app).to receive(:call)
      .with(a_hash_including(
        'rack.request.query_hash' => {
          'author' => 'test_author_id',
          'category' => 'test_category_id'
        }
      ))
      .once
      .and_call_original

    subject.call(env)
  end

  it 'applies migrations downwards to the response' do
    expect(JSON.parse(subject.call(env).last.first)).to eq(
      'author_id' => 'test_author_id',
      'category_id' => 'test_category_id'
    )
  end
end

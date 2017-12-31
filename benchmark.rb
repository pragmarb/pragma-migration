# frozen_string_literal: true

require 'benchmark'
require 'json'

require 'bundler/setup'
require 'pragma/migration'

class RemoveIdFromAuthor < Pragma::Migration::Base
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

class AddIdToAuthor < Pragma::Migration::Base
  apply_to '/api/v1/posts/*'

  def up
    request.update_param('author_id', request.delete_param('author'))
  end

  def down
    parsed_body = JSON.parse(response.body.join(''))
    Rack::Response.new(
      JSON.dump(parsed_body.merge('author' => parsed_body.delete('author_id'))),
      response.status,
      response.headers
    )
  end
end

class Repository < Pragma::Migration::Repository
  migrations = [RemoveIdFromAuthor, AddIdToAuthor] * 500

  version '2017-12-25'

  version '2017-12-26', migrations
  version '2017-12-27', migrations
  version '2017-12-28', migrations
end

request = Rack::Request.new(Rack::MockRequest.env_for('/api/v1/posts/1',
  method: :patch,
  params: {
    'author_id' => 'test_author_id',
    'category_id' => 'test_category_id'
  }
))

response = Rack::Response.new(JSON.dump(
  author: 'test_author_id',
  category: 'test_category_id'
))

puts "Running 2k migrations, up and down:\n"

Benchmark.bm do |x|
  x.report do
    runner = Pragma::Migration::Runner.new(Pragma::Migration::Bond.new(
      repository: Repository,
      request: request,
      user_version: '2017-12-26'
    ))

    runner.run_upwards
    runner.run_downwards(response)
  end
end

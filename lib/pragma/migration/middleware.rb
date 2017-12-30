# frozen_string_literal: true

module Pragma
  module Migration
    class Middleware
      def initialize(app, repository:)
        @app = app
        @repository = repository
        @runner = Runner.new(@repository)
      end

      def call(env)
        original_request = Rack::Request.new(env)
        migrated_request = @runner.run_upwards(original_request)

        status, headers, body = @app.call(migrated_request.env)
        original_response = Rack::Response.new(body, status, headers)
        migrated_response = @runner.run_downwards(original_request, original_response)

        [migrated_response.status, migrated_response.headers, migrated_response.body]
      end
    end
  end
end

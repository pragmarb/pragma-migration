# frozen_string_literal: true

module Pragma
  module Migration
    class Middleware
      DEFAULT_VERSION_PROC = lambda do |request|
        request.get_header('X-Api-Version')
      end

      def initialize(app, repository:, user_version_proc: DEFAULT_VERSION_PROC)
        @app = app
        @repository = repository
        @user_version_proc = user_version_proc
      end

      def call(env)
        original_request = Rack::Request.new(env)

        runner = Runner.new(Bond.new(
          repository: @repository,
          request: original_request,
          user_version: user_version_from(original_request)
        ))

        migrated_request = runner.run_upwards

        status, headers, body = @app.call(migrated_request.env)
        original_response = Rack::Response.new(body, status, headers)
        migrated_response = runner.run_downwards(original_response)

        [migrated_response.status, migrated_response.headers, migrated_response.body]
      end

      private

      def user_version_from(request)
        version = @user_version_proc.call(request)
        @repository.sorted_versions.include?(version) ? version : @repository.sorted_versions.last
      end
    end
  end
end

# frozen_string_literal: true

module Pragma
  module Migration
    # Rack middleware for migrating requests and responses.
    #
    # This middleware can be added to your Rack application in order to automatically migrate your
    # users' requests up and your app's responses down.
    #
    # @example Configuring the middleware
    #   use Pragma::Migration::Middleware,
    #     repository: API::V1::MigrationRepository,
    #     user_version_proc: (lambda do |request|
    #       # `request` here is a `Rack::Request` object.
    #       request.get_header 'X-Api-Version'
    #     end)
    class Middleware
      # The default for +user_version_proc+.
      DEFAULT_VERSION_PROC = lambda do |request|
        request.get_header('X-Api-Version')
      end

      # Initializes the middleware.
      #
      # @param app [Object] your app
      # @param repository [Repository] your migration repository
      # @param user_version_proc [Proc] a proc that takes a request and returns a version number
      def initialize(app, repository:, user_version_proc: DEFAULT_VERSION_PROC)
        @app = app
        @repository = repository
        @user_version_proc = user_version_proc
      end

      # Executes the middleware.
      #
      # This will take the provided environment, build a request with it and run the migrations
      # upwards to make the request compatible with the latest API version.
      #
      # It will then pass this request on so that it is handled by your application.
      #
      # The response returned by your application will be migrated downwards so that it is
      # compatible with the version of the API supported by the client.
      #
      # @param env [Hash] the Rack env
      #
      # @return [Array<Integer, Hash, Enumerable>] an array with the status, headers and body of
      #   the final response for the user
      #
      # @see Runner
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

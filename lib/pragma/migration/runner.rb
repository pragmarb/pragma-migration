# frozen_string_literal: true

module Pragma
  module Migration
    # Runners run the migrations of a {Bond} on requests/responses.
    class Runner
      # @!attribute [r] bond
      #   @return [Bond] the bond used by this runner
      attr_reader :bond

      # Initializes the runner.
      #
      # @param bond [Bond] the bond to use
      def initialize(bond)
        @bond = bond
      end

      # Returns the request this runner is operating on.
      #
      # This is just a shortcut for the bond's request.
      #
      # @return [Rack::Request]
      #
      # @see Bond#request
      def request
        bond.request
      end

      # Returns the repository this runner is operating with.
      #
      # This is just a shortcut for the bond's repository.
      #
      # @return [Repository]
      #
      # @see Bond#repository
      def repository
        bond.repository
      end

      # Runs all the migrations applying to the request upwards.
      #
      # Note that only the first migration is run with the original request: each migration after
      # the first will be run with the request returned by the previous migration.
      #
      # @return [Rack::Request] the final request
      #
      # @see Bond#applying_migrations
      # @see Base.up
      def run_upwards
        result = request

        bond.applying_migrations.each do |migration|
          result = migration.up(result)
        end

        result
      end

      # Runs all the migrations applying to the request downwards.
      #
      # Note that only the first migration is run with the original response: each migration after
      # the first will be run with the response returned by the previous migration.
      #
      # Also, when running downwards the migration's request is always the user's original request.
      #
      # @return [Rack::Response] the final response
      #
      # @see Bond#applying_migrations
      # @see Base.down
      def run_downwards(response)
        result = response

        bond.applying_migrations.reverse.each do |migration|
          result = migration.down(request, result)
        end

        result
      end
    end
  end
end

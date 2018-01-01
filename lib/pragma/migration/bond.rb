# frozen_string_literal: true

module Pragma
  module Migration
    # Bonds are links between a migration repository, a user request and an API version.
    #
    # By containing all the information needed to determine the state of each migration, they can
    # more effectively cache data.
    #
    # @api private
    class Bond
      # @!attribute [r] repository
      #   @return [Repository] the migration repository to use for this bond
      #
      # @!attribute [r] request
      #   @return [Rack::Request] the request this bond will work with
      #
      # @!attribute [r] user_version
      #   @return [String] the user's API version, usually determined with +user_version_proc+
      attr_reader :repository, :request, :user_version

      # Initializes the bond.
      #
      # @param repository [Repository] the repository to use
      # @param request [Rack::Request] the request to work with
      # @param user_version [String] the user's API version
      def initialize(repository:, request:, user_version:)
        @repository = repository
        @request = request
        @user_version = user_version
      end

      # Returns the migrations that must be applied on the user's API version.
      #
      # The results of this method are cached and returned on subsequent requests.
      #
      # Note that a call to this method will also compute and cache {#rolled_migrations} and
      # (partially) {#applying_migrations}.
      #
      # @return [Array<Base>]
      def pending_migrations
        allocate_migrations unless @pending_migrations
        @pending_migrations
      end

      # Returns the migrations that have already been rolled/applied on the user's API version.
      #
      # The results of this method are cached and returned on subsequent requests.
      #
      # Note that a call to this method will also compute and cache {#pending_migrations} and
      # (partially) {#applying_migrations}.
      #
      # @return [Array<Base>]
      def rolled_migrations
        allocate_migrations unless @rolled_migrations
        @rolled_migrations
      end

      # Returns the migrations that must be applied to the request, i.e. the intersection of
      # {#pending_migrations} and migrations whose {Base.applies_to?} returns +true+.
      #
      # The results of this method are cached and returned on subsequent requests.
      #
      # Note that a call to this method will also compute and cache {#pending_migrations} and
      # {#rolled_migrations}.
      #
      # @return [Array<Base>]
      def applying_migrations
        compute_applying_migrations unless @applying_migrations
        @applying_migrations
      end

      # Returns whether a migration is pending.
      #
      # This is just a convenience method that calls {#pending_migrations} and checks whether the
      # provided object is part of it.
      #
      # @param migration [Base] the migration to check
      #
      # @return [Boolean] whether the migration is pending
      def migration_pending?(migration)
        pending_migrations.include?(migration)
      end

      # Returns whether a migration has been rolled.
      #
      # This is just a convenience method that calls {#rolled_migrations} and checks whether the
      # provided object is part of it.
      #
      # @param migration [Base] the migration to check
      #
      # @return [Boolean] whether the migration has been rolled
      def migration_rolled?(migration)
        rolled_migrations.include?(migration)
      end

      # Returns whether a migration applies to the request.
      #
      # This is just a convenience method that calls {#applying_migrations} and checks whether the
      # provided object is part of it.
      #
      # @param migration [Base] the migration to check
      #
      # @return [Boolean] whether the migration applies to the request
      def migration_applies?(migration)
        applying_migrations.include?(migration)
      end

      private

      def allocate_migrations
        @pending_migrations = []
        @rolled_migrations = []

        repository.sorted_versions.each do |version|
          if version > user_version
            @pending_migrations += version.migrations
          else
            @rolled_migrations += version.migrations
          end
        end
      end

      def compute_applying_migrations
        @applying_migrations = []

        pending_migrations.each do |migration|
          @applying_migrations << migration if migration.applies_to?(request)
        end
      end
    end
  end
end

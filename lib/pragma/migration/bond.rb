# frozen_string_literal: true

module Pragma
  module Migration
    class Bond
      attr_reader :repository, :request, :user_version

      def initialize(repository:, request:, user_version:)
        @repository = repository
        @request = request
        @user_version = user_version
      end

      def pending_migrations
        allocate_migrations unless @pending_migrations
        @pending_migrations
      end

      def rolled_migrations
        allocate_migrations unless @rolled_migrations
        @rolled_migrations
      end

      def applying_migrations
        compute_applying_migrations unless @applying_migrations
        @applying_migrations
      end

      def migration_pending?(migration)
        pending_migrations.include?(migration)
      end

      def migration_rolled?(migration)
        rolled_migrations.include?(migration)
      end

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

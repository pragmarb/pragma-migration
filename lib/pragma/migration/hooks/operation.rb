# frozen_string_literal: true

module Pragma
  module Migration
    module Hooks
      # Provides hooks for Pragma::Operation to use and query migrations.
      module Operation
        # Returns the migrations that have already been rolled/applied on the user's API version.
        #
        # @param options [Trailblazer::Context] the +options+ hash passed to the operation's steps
        #
        # @return [Array<Pragma::Migration::Base>]
        #
        # @see Pragma::Migration::Bond#rolled_migrations
        def rolled_migrations(options)
          build_migration_bond(options).rolled_migrations
        end

        # Returns the migrations that must be applied to the request.
        #
        # @param options [Trailblazer::Context] the +options+ hash passed to the operation's steps
        #
        # @return [Array<Pragma::Migration::Base>]
        #
        # @see Pragma::Migration::Bond#applying_migrations
        def applying_migrations(options)
          build_migration_bond(options).applying_migrations
        end

        # Returns the migrations that must be applied on the user's API version.
        #
        # @param options [Trailblazer::Context] the +options+ hash passed to the operation's steps
        #
        # @return [Array<Pragma::Migration::Base>]
        #
        # @see Pragma::Migration::Bond#pending_migrations
        def pending_migrations(options)
          build_migration_bond(options).pending_migrations
        end

        # Returns whether a migration has been rolled.
        #
        # @param options [Trailblazer::Context] the +options+ hash passed to the operation's steps
        # @param migration [Base] the migration to check
        #
        # @return [Boolean] whether the migration is pending
        #
        # @see Pragma::Migration::Bond#migration_rolled?
        def migration_rolled?(options, migration)
          build_migration_bond(options).migration_rolled?(migration)
        end

        # Returns whether a migration applies to the request.
        #
        # @param options [Trailblazer::Context] the +options+ hash passed to the operation's steps
        # @param migration [Base] the migration to check
        #
        # @return [Boolean] whether the migration is pending
        #
        # @see Pragma::Migration::Bond#migration_applies?
        def migration_applies?(options, migration)
          build_migration_bond(options).migration_applies?(migration)
        end

        # Returns whether a migration is pending.
        #
        # @param options [Trailblazer::Context] the +options+ hash passed to the operation's steps
        # @param migration [Base] the migration to check
        #
        # @return [Boolean] whether the migration is pending
        #
        # @see Pragma::Migration::Bond#migration_pending?
        def migration_pending?(options, migration)
          build_migration_bond(options).migration_pending?(migration)
        end

        private

        def build_migration_bond(options)
          options['migration.bond'] ||= Bond.new(
            repository: Pragma::Migration.config.repository,
            request: options['rack.request'],
            user_version_proc: Pragma::Migration.config.user_version_proc
          )
        end

        ::Pragma::Operation::Base.prepend(self) if defined?(::Pragma::Operation::Base)
      end
    end
  end
end

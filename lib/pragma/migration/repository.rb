# frozen_string_literal: true

module Pragma
  module Migration
    # Repositories are collections of API versions.
    #
    # Your API should have one migration repository per major version. This repository will contain
    # all the minor versions of your API, each with its own collection of migrations.
    class Repository
      class << self
        # Returns a sorted collection of API versions.
        #
        # Note that the array returned by this method is a duplicate of the original, so any
        # manipulations will not be applied to the repository's collection.
        #
        # @return [Array<Version>]
        def sorted_versions
          versions.dup
        end

        protected

        # Defines a new version of your API.
        #
        # Note that the initial version of your API should not have any migrations, as these will
        # never be applied.
        #
        # @param number [String] a version number (you can use anything here as long as it can be
        #   compared by +Gem::Version+)
        # @param migrations [Array<Base>] the migrations in this version
        #
        # @return [Version] the new version
        def version(number, migrations = [])
          Version.new(number, migrations).tap do |version|
            versions << version
            sort_versions
          end
        end

        private

        def versions
          @versions ||= []
        end

        def sort_versions
          @versions = @versions.sort
        end
      end
    end
  end
end

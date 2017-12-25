# frozen_string_literal: true

module Pragma
  module Migration
    class Repository
      class << self
        def version(number, migrations = [])
          versions << Version.new(number, migrations)
          sort_versions
        end

        def sorted_versions
          versions.dup
        end

        def migrations_since(user_version)
          @versions.select { |version| version > user_version }.flat_map(&:migrations)
        end

        def migration_active?(user_version, migration)
          @versions.any? do |version|
            version > user_version && version.migration?(migration)
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

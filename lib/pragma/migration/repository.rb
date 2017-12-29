# frozen_string_literal: true

module Pragma
  module Migration
    class Repository
      class << self
        def sorted_versions
          versions.dup
        end

        def user_version_proc
          @user_version_proc ||= lambda do |request|
            request.get_header('X-Api-Version')
          end
        end

        def migrations_since(request_or_version)
          user_version = if request_or_version.is_a?(Rack::Request)
            user_version_from(request_or_version)
          else
            request_or_version
          end

          @versions.select { |version| version > user_version }.flat_map(&:migrations)
        end

        def migrations_for(request)
          migrations_since(request).select do |migration|
            migration.applies_to?(request)
          end
        end

        def migration_active?(migration, request: nil, user_version: nil)
          unless request || user_version
            fail ArgumentError, 'You must pass one of :request or :user_version'
          end

          user_version ||= user_version_from(request)

          @versions.any? do |version|
            version > user_version && version.migration?(migration)
          end
        end

        protected

        def user_version_from(request)
          user_version = user_version_proc.call(request)
          sorted_versions.include?(user_version) ? user_version : sorted_versions.last
        end

        def version(number, migrations = [])
          versions << Version.new(number, migrations)
          sort_versions
        end

        def user_version(&block)
          @user_version_proc = block
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

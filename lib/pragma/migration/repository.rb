# frozen_string_literal: true

module Pragma
  module Migration
    class Repository
      class << self
        def sorted_versions
          versions.dup
        end

        def user_version_from(request)
          user_version = user_version_proc.call(request)
          sorted_versions.include?(user_version) ? user_version : sorted_versions.last
        end

        protected

        def version(number, migrations = [])
          versions << Version.new(number, migrations)
          sort_versions
        end

        def determine_version_with(&block)
          @user_version_proc = block
        end

        def user_version_proc
          @user_version_proc ||= lambda do |request|
            request.get_header('X-Api-Version')
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

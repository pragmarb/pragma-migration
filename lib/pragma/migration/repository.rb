# frozen_string_literal: true

module Pragma
  module Migration
    class Repository
      class << self
        def sorted_versions
          versions.dup
        end

        protected

        def version(number, migrations = [])
          versions << Version.new(number, migrations)
          sort_versions
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

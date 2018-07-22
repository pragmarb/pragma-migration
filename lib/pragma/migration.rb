# frozen_string_literal: true

require 'rack'
require 'mustermann'

require 'pragma/migration/configuration'
require 'pragma/migration/base'
require 'pragma/migration/repository'
require 'pragma/migration/version'
require 'pragma/migration/runner'
require 'pragma/migration/bond'
require 'pragma/migration/middleware'
require 'pragma/migration/hooks/operation'
require 'pragma/migration/gem_version'

module Pragma
  # Provides API payload migrations to support clients on older versions of your API.
  module Migration
    class << self
      # Returns the current configuration.
      #
      # @return [Configuration]
      def config
        @config ||= Configuration.new
      end

      # Yields the current configuration for editing.
      #
      # @yield [Configuration]
      def configure
        yield config
      end
    end
  end
end

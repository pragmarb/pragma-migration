# frozen_string_literal: true

require 'rack'
require 'mustermann'

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
    # The default +user_version_proc+.
    DEFAULT_USER_VERSION_PROC = lambda do |request|
      request.get_header('X-Api-Version')
    end

    class << self
      # @!attribute [rw] repository
      #   @return [Pragma::Migration::Repository] your migrations repository
      #
      # @!attribute [rw] user_version_proc
      #   @return [Object] a callable taking a +Rack::Request+ as argument and returning an API
      #     version identifier
      attr_accessor :repository
      attr_writer :user_version_proc

      def user_version_proc
        @user_version_proc ||= DEFAULT_USER_VERSION_PROC
      end
    end
  end
end

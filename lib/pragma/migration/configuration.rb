# frozen_string_literal: true

module Pragma
  module Migration
    # Holds configuration information about the setup of your migrations.
    class Configuration
      # The default +user_version_proc+.
      DEFAULT_USER_VERSION_PROC = lambda do |request|
        request.get_header('X-Api-Version')
      end

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

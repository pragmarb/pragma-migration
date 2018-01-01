# frozen_string_literal: true

module Pragma
  module Migration
    # A migration describes a change in your API's request or response payloads.
    #
    # API migrations can be run in two directions: up when a client on an old version performs a
    # request, and down when the response from the latest version must be converted into one that
    # the client can understand.
    #
    # Migrations can also skip the definition of the up and down logic, in which case they become
    # no-ops. This is useful when containing side effects (for instance, you can use a migration
    # just to indicate that a certain behavior has become opt-out rather than opt-in). You can check
    # the readme for more details on how to use no-op migrations.
    #
    # @example A regular migration
    #   class RemoveIdSuffixFromAuthorInArticles < Pragma::Migration::Base
    #     apply_to '/api/v1/articles/:id'
    #     describe 'The _id suffix has been removed from the author property in the Articles API.'
    #
    #     def up
    #       request.update_param 'author', request.delete_param('author_id')
    #     end
    #
    #     def down
    #       parsed_body = JSON.parse(response.body.join(''))
    #       Rack::Response.new(
    #         JSON.dump(parsed_body.merge('author' => parsed_body['author_id'])),
    #         response.status,
    #         response.headers
    #       )
    #     end
    #   end
    #
    # @example A no-op migration
    #   class NotifyArticleSubscribersAutomatically < Pragma::Migration::Base
    #     describe 'Subscribers are now notified of new articles automatically.'
    #   end
    class Base
      class << self
        # @!attribute [r] pattern
        #   @return [String] The pattern that the request path must match in order for the migration
        #     to be applied. This is a pattern compatible with Mustermann.
        #
        # @!attribute [r] description
        #   @return [String] The migration's description. Not used by Pragma::Migration in any way,
        #     but can be used by documentation tools to create a changelog automatically.
        attr_reader :pattern, :description

        # Checks whether the migration applies to the request.
        #
        # By default, this checks whether the migration's pattern matches the request's path, but
        # more complex logic can be implemented by overriding this method (it is recommended to
        # retain the original behavior as well).
        #
        # Note that you shouldn't check the version of the user in this method: when this method is
        # called, it has already been determined that the migration applies to the user's API
        # version.
        #
        # @param request [Rack::Request] the request to check
        #
        # @return [Boolean] whether the migration applies to the request
        #
        # @example Override the check
        #   def self.applies_to?(request)
        #     super && request.get_header('X-Custom-Header') == '1'
        #   end
        def applies_to?(request)
          return false unless pattern
          request.path =~ Mustermann.new(pattern)
        end

        # Migrates the user's request up.
        #
        # This is a convenience method that instantiates the migration with the provided request and
        # runs {#up}.
        #
        # @param request [Rack::Request] the user's request
        #
        # @return [Rack::Request] if the value returned by {#up} is an instance of +Rack::Request+,
        #   the new request is returned, otherwise the existing request is returned
        #
        # @note This method should not be overridden. You should override the instance-level {#up}
        #   method instead.
        def up(request)
          result = new(request: request).up
          result.is_a?(Rack::Request) ? result : request
        end

        # Migrates the API's response down.
        #
        # This is a convenience method that instantiates the migration with the provided request and
        # response and runs {#down}.
        #
        # @param request [Rack::Request] the user's request
        # @param response [Rack::Response] the API's response
        #
        # @return [Rack::Request] if the value returned by {#down} is an instance of
        #   +Rack::Response+, the new response is returned, otherwise the existing response is
        #   returned
        #
        # @note This method should not be overridden. You should override the instance-level {#down}
        #   method instead.
        def down(request, response)
          result = new(request: request, response: response).down
          result.is_a?(Rack::Response) ? result : response
        end

        protected

        # Sets the pattern this migration should be applied to.
        #
        # This should be a Mustermann-compatible pattern, like +/api/v1/posts/:id+.
        #
        # @param pattern [String] a Mustermann pattern
        #
        # @see https://github.com/sinatra/mustermann/
        def apply_to(pattern)
          @pattern = pattern
        end

        # Sets the migration's description.
        #
        # @param description [String] the description
        def describe(description)
          @description = description
        end
      end

      # @!attribute [r] request
      #   @return [Rack::Request] The request this migration is being applied to. This will be
      #     either the user's original request or one that's already been modified by previous
      #     migrations.
      attr_reader :request

      # Initializes the migration.
      #
      # The migration will be instantiated only with a request when it's being run upwards, and with
      # both a request and a response when it's being run downwards.
      #
      # @param request [Rack::Request] the request to migrate
      # @param response [Rack::Response] the response to migrate
      def initialize(request:, response: nil)
        @request = request
        @response = response
      end

      # Returns the response the migration was instantiated with.
      #
      # @return [Rack::Response]
      #
      # @raise [RuntimeError] when the migration is being run upwards
      #
      # @todo Create our own exception class for when the response is not accessible.
      def response
        fail 'Cannot access response when migrating upwards!' unless @response
        @response
      end

      # Migrates the request up.
      #
      # This method should alter the migration's {#request} in such a way that the request will be
      # compatible with the new API version.
      #
      # @return [Rack::Request|Object] if a +Rack::Request+ object is returned, the user's request
      #   will be replaced with the new one, otherwise the existing request will be used
      def up; end

      # Migrates the response down.
      #
      # This method should alter the migration's {#response} in such a way that the response will be
      # compatible with clients running on the old API version.
      #
      # @return [Rack::Response|Object] if a +Rack::Response+ object is returned, the API's response
      #   will be replaced with the new one, otherwise the existing response will be used
      def down; end
    end
  end
end

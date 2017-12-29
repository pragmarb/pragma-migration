# frozen_string_literal: true

module Pragma
  module Migration
    class Base
      class << self
        attr_reader :pattern, :description

        def applies_to?(request)
          request.path =~ Mustermann.new(pattern)
        end

        def up(request)
          result = new(request: request).up
          result.is_a?(Rack::Request) ? result : request
        end

        def down(request, response)
          result = new(request: request, response: response).down
          result.is_a?(Rack::Response) ? result : response
        end

        protected

        def apply_to(pattern)
          @pattern = pattern
        end

        def describe(description)
          @description = description
        end
      end

      attr_reader :request

      def initialize(request:, response: nil)
        @request = request
        @response = response
      end

      def response
        fail 'Cannot access response when migrating upwards!' unless @response
        @response
      end

      def up; end

      def down; end
    end
  end
end

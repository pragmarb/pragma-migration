# frozen_string_literal: true

module Pragma
  module Migration
    class Base
      class << self
        attr_reader :pattern, :description

        def apply_to(pattern)
          @pattern = pattern
        end

        def describe(description)
          @description = description
        end
      end

      def up(request)
        request
      end

      def down(response)
        response
      end
    end
  end
end

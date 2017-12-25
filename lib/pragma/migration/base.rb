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

      def up(_request)
        fail NotImplementedError
      end

      def down(_response)
        fail NotImplementedError
      end
    end
  end
end

# frozen_string_literal: true

module Pragma
  module Migration
    class Version
      attr_reader :number, :migrations

      def initialize(number, migrations = [])
        @number = number
        @migrations = migrations
      end

      def >(other)
        self.<=>(other) == 1
      end

      def <(other)
        self.<=>(other) == -1
      end

      def ==(other)
        self.<=>(other).zero?
      end

      def <=>(other)
        other_number = other.is_a?(self.class) ? other.number : other
        Gem::Version.new(number) <=> Gem::Version.new(other_number)
      end

      def migration?(migration)
        @migrations.include?(migration)
      end
    end
  end
end

# frozen_string_literal: true

module Pragma
  module Migration
    # Represents a version of your API.
    #
    # This class is used for comparing and sorting API versions and for holding the migrations
    # associated to each version.
    #
    # Usually, versions are instantiated via {Repository.version}.
    class Version
      # @!attribute [r] number
      #   @return [String] the number of this version
      #
      # @!attribute [r] migrations
      #   @return [Array<Base>] the migrations in this version
      attr_reader :number, :migrations

      # Initializes the version.
      #
      # @param number [String] the version number (this can be anything comparable with
      #   +Gem::Version+)
      # @param migrations [Array<Base>] the migrations in this version
      def initialize(number, migrations = [])
        @number = number
        @migrations = migrations
      end

      # Returns whether this version is greater than the provided version.
      #
      # @param other [Version|String] a version or version number
      #
      # @return [Boolean] whether this version is greater than the provided one
      def >(other)
        self.<=>(other) == 1
      end

      # Returns whether this version is smaller than the provided version.
      #
      # @param other [Version|String] a version or version number
      #
      # @return [Boolean] whether this version is smaller than the provided one
      def <(other)
        self.<=>(other) == -1
      end

      # Returns whether this version is equal than the provided version.
      #
      # @param other [Version|String] a version or version number
      #
      # @return [Boolean] whether this version is equal than the provided one
      def ==(other)
        self.<=>(other).zero?
      end

      # Returns whether this version is greater than or equal to the provided version.
      #
      # @param other [Version|String] a version or version number
      #
      # @return [Boolean] whether this version is greater than or equal to the provided one
      def >=(other)
        cmp = self.<=>(other)
        cmp == 1 || cmp.zero?
      end

      # Returns whether this version is smaller than or equal to the provided version.
      #
      # @param other [Version|String] a version or version number
      #
      # @return [Boolean] whether this version is smaller than or equal to the provided one
      def <=(other)
        cmp = self.<=>(other)
        cmp == -1 || cmp.zero?
      end

      # Compares this version with another.
      #
      # @param other [Version|String] a version or version number
      #
      # @return [Integer] -1 if this version is smaller than the other, 0 if they are equal and 1
      #   if this version is greater than the other
      def <=>(other)
        other_number = other.is_a?(self.class) ? other.number : other
        Gem::Version.new(number) <=> Gem::Version.new(other_number)
      end

      # Returns whether a migration is present in this version.
      #
      # @param migration [Class] a migration class
      #
      # @return [Boolean] whether this version contains the given migration
      def migration?(migration)
        @migrations.include?(migration)
      end
    end
  end
end

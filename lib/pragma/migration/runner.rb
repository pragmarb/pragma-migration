# frozen_string_literal: true

module Pragma
  module Migration
    class Runner
      attr_reader :bond

      def initialize(bond)
        @bond = bond
      end

      def request
        bond.request
      end

      def repository
        bond.repository
      end

      def run_upwards
        result = request

        bond.applying_migrations.each do |migration|
          result = migration.up(result)
        end

        result
      end

      def run_downwards(response)
        result = response

        bond.applying_migrations.reverse.each do |migration|
          result = migration.down(request, result)
        end

        result
      end
    end
  end
end

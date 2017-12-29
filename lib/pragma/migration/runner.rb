# frozen_string_literal: true

module Pragma
  module Migration
    class Runner
      attr_reader :repository

      def initialize(repository)
        @repository = repository
      end

      def run_upwards(request)
        repository.migrations_for(request).each do |migration|
          request = migration.up(request)
        end

        request
      end

      def run_downwards(request, response)
        repository.migrations_for(request).reverse.each do |migration|
          response = migration.down(request, response)
        end

        response
      end
    end
  end
end

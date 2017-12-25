# frozen_string_literal: true

module Pragma
  module Migration
    class Runner
      attr_reader :repository, :user_version

      def initialize(repository:, user_version:)
        @repository = repository
        @user_version = user_version
      end

      def run_upwards(request)
        repository.migrations_since(user_version).each do |migration|
          request = migration.new.up(request)
        end

        request
      end

      def run_downwards(response)
        repository.migrations_since(user_version).reverse.each do |migration|
          response = migration.new.down(response)
        end

        response
      end
    end
  end
end

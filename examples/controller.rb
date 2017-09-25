module API
  module V1
    class ResourceController < ApplicationController
      include Pragma::Rails::ResourceController

      private

      # Latest version is assumed if returns nil.
      def current_version
        request.headers['Api-Version'] || current_user&.version
      end
    end
  end
end

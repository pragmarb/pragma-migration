# frozen_string_literal: true

require 'rack'
require 'mustermann'

require 'pragma/migration/base'
require 'pragma/migration/repository'
require 'pragma/migration/version'
require 'pragma/migration/runner'
require 'pragma/migration/bond'
require 'pragma/migration/middleware'
require 'pragma/migration/gem_version'

module Pragma
  # Provides API payload migrations to support clients on older versions of your API.
  module Migration
  end
end

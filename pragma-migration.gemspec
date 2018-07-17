# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pragma/migration/gem_version'

Gem::Specification.new do |spec|
  spec.name          = 'pragma-migration'
  spec.version       = Pragma::Migration::VERSION
  spec.authors       = ['Alessandro Desantis']
  spec.email         = ['desa.alessandro@gmail.com']

  spec.summary       = 'Stripe-style API versioning.'
  spec.homepage      = 'https://github.com/pragmarb/pragma-migration'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'mustermann', '~> 1.0'
  spec.add_dependency 'rack', '~> 2.0'

  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'pragma-operation'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
end

# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tentd-omnibus/version'

Gem::Specification.new do |gem|
  gem.name          = "tentd-omnibus"
  gem.version       = TentD::Omnibus::VERSION
  gem.authors       = ["Jesse Stuart"]
  gem.email         = ["jesse@jessestuart.ca"]
  gem.description   = %q{TentD bundle with status and admin apps}
  gem.summary       = %q{TentD bundle with status and admin apps}
  gem.homepage      = "http://tent.io"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'tentd', '~> 0.2'
  gem.add_runtime_dependency 'tent-status'
  gem.add_runtime_dependency 'rack-putty'
  gem.add_runtime_dependency 'unicorn'
  gem.add_runtime_dependency 'sidekiq'
  gem.add_runtime_dependency 'mimetype-fu'
  gem.add_runtime_dependency 'bcrypt-ruby'
end

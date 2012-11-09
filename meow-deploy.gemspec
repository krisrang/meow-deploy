# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'meow-deploy/version'

Gem::Specification.new do |gem|
  gem.name          = "meow-deploy"
  gem.version       = MeowDeploy::VERSION
  gem.authors       = "Kristjan Rang"
  gem.email         = "mail@kristjanrang.eu"
  gem.description   = %q{Tasks for deploying to a stack running god, rbenv and whatever rails server}
  gem.summary       = %q{Capistrano tasks for a god-rbenv-whatever stack}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'capistrano'
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'boxcli/version'

Gem::Specification.new do |spec|
  spec.name          = "boxcli"
  spec.version       = Boxcli::VERSION
  spec.authors       = ["Nitrous.IO Engineering"]
  spec.email         = ["eng@nitrous.io"]
  spec.license       = "MIT"
  spec.summary       = %q{Boxhost CLI}
  spec.description   = %q{Boxhost CLI}

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.executables   = ['boxcli']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_dependency "pry"
  spec.add_dependency "pg"
  spec.add_dependency "activerecord"
  spec.add_dependency "redis"
end

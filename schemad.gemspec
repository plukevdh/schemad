# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'schemad/version'

Gem::Specification.new do |spec|
  spec.name          = "schemad"
  spec.version       = Schemad::VERSION
  spec.authors       = ["Luke van der Hoeven"]
  spec.email         = ["hi@plukevdh.me"]
  spec.summary       = %q{Simple schema DSL for services}
  spec.description   = %q{
    This gem allows easy attribute definition, type casting and special handling
    of data returned from a service of some kind. It's meant to be incredibly general
    purpose. Maybe this is a bad idea...
  }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 7.0"

  spec.add_development_dependency "bundler", "~> 2.3"
  spec.add_development_dependency "rake"
end

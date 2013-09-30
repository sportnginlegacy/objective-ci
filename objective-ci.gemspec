# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'objective_ci/version'

Gem::Specification.new do |spec|
  spec.name          = "objective-ci"
  spec.version       = ObjectiveCi::VERSION
  spec.authors       = ["Mark Larsen"]
  spec.email         = ["mark.larsen@sportngin.com"]
  spec.description   = %q{CI tools for objective-c}
  spec.summary       = %q{CI tools for objective-c}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "ocunit2junit"
  spec.add_dependency "nokogiri"
end

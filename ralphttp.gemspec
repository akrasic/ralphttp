# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ralphttp/version'

Gem::Specification.new do |spec|
  spec.name          = "ralphttp"
  spec.version       = Ralphttp::VERSION
  spec.authors       = ["Antun Krasic"]
  spec.email         = ["antun@martuna.co"]
  spec.description   = %q{HTTP performance testing tool}
  spec.summary       = %q{Test the HTTP performance}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end

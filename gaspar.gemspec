# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gaspar/version'

Gem::Specification.new do |spec|
  spec.name          = "gaspar"
  spec.version       = Gaspar::VERSION
  spec.authors       = ["5rabbits"]
  spec.email         = ["info@5rabbits.com"]
  spec.description   = %q{ Convert PDF tables to HTML, JSON, XML and more. }
  spec.summary       = %q{ Convert PDF tables to HTML, JSON, XML and more. }
  spec.homepage      = "https://github.com/5rabbits/gaspar"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "spoon"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "nokogiri"
  spec.add_development_dependency "rspec"
end

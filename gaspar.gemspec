# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gaspar/version'

Gem::Specification.new do |spec|
  spec.name          = 'gaspar'
  spec.version       = Gaspar::VERSION
  spec.authors       = ['5rabbits', 'Abraham Barrera']
  spec.email         = ['abarrerac@gmail.com']
  spec.description   = 'Parses PDF tables into HTML, JSON, XML and more.'
  spec.summary       = 'Parses PDF tables into HTML, JSON, XML and more.'
  spec.homepage      = 'https://github.com/5rabbits/gaspar'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($RS)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'spoon'
  spec.add_dependency 'pdf-reader'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'nokogiri'
  spec.add_development_dependency 'rspec'
end

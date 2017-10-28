# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_params/version'

Gem::Specification.new do |spec|
  spec.name = 'simple_params'
  spec.version = SimpleParams::VERSION
  spec.authors = ['brycesenz']
  spec.email = ['bryce.senz@gmail.com']
  spec.description = %q{Simple way to specify API params}
  spec.summary = %q{A DSL for specifying params, including type coercion and validation}
  spec.homepage = 'https://github.com/brycesenz/simple_params'
  spec.license = 'MIT'

  spec.files = `git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel', '>= 3.0', '<= 6.0'
  spec.add_dependency 'virtus', '>= 1.0.0'
  spec.add_dependency 'shoulda-matchers', '~> 2.8'
  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake', '~> 10.1'
  spec.add_development_dependency 'rspec', '~> 2.6'
  spec.add_development_dependency 'pry'
end

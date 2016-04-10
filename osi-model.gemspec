# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'osi/model/version'

Gem::Specification.new do |spec|
  spec.name = 'osi-model'
  spec.version = Osi::Model::VERSION
  spec.authors = ['Roman Lishtaba']
  spec.email = ['roman@lishtaba.com']

  spec.summary = 'OSI Model implementation'
  spec.description = 'OSI Model implementation intended to be used by communication protocols'
  spec.homepage = 'https://github.com/rlishtaba/markov_text_generator'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'cucumber', '~> 1.3'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'yard'
  spec.add_dependency 'functional-ruby', '=1.3.0'
  spec.add_dependency 'concurrent-ruby'
  spec.add_dependency 'rs_232', '= 2.0.7'
end

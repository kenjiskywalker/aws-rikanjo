# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws/rikanjo/version'

Gem::Specification.new do |spec|
  spec.name          = 'aws-rikanjo'
  spec.version       = '0.0.9'
  spec.authors       = ['kenjiskywalker']
  spec.email         = ['git@kenjiskywalker.org']
  spec.description   = %q{AWS RI Cost Calc Tool}
  spec.summary       = %q{calc 1 year cost. check sweet spot}
  spec.homepage      = 'https://github.com/kenjiskywalker/aws-rikanjo'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.0'
  spec.add_dependency 'rake'
  spec.add_dependency 'yajl-ruby'

  spec.bindir = 'bin'
  spec.executables << 'rikanjo'
end

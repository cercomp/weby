# -*- encoding: utf-8 -*-

require File.join(File.dirname(__FILE__), 'lib', 'callsite', 'version')

Gem::Specification.new do |s|
  s.name = %q{callsite}
  s.version = Callsite::VERSION
  s.authors = ["Joshua Hull"]
  s.description = %q{Caller/backtrace parser with some useful utilities for manipulating the load path, and doing other relative things.}
  s.email = %q{joshbuddy@gmail.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = `git ls-files`.split("\n")
  s.homepage = %q{http://github.com/joshbuddy/callsite}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Caller/backtrace parser with some useful utilities for manipulating the load path, and doing other relative things.}
  s.license = "MIT"

  s.test_files = `git ls-files`.split("\n").select{|f| f[/^spec/]}

  s.add_development_dependency 'bundler', '~> 1.0.0'
  s.add_development_dependency 'rake',    '~> 0.8.7'
  s.add_development_dependency 'rspec',   '~> 1.3.0'
end


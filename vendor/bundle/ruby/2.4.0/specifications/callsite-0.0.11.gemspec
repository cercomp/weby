# -*- encoding: utf-8 -*-
# stub: callsite 0.0.11 ruby lib

Gem::Specification.new do |s|
  s.name = "callsite".freeze
  s.version = "0.0.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Joshua Hull".freeze]
  s.date = "2011-11-10"
  s.description = "Caller/backtrace parser with some useful utilities for manipulating the load path, and doing other relative things.".freeze
  s.email = "joshbuddy@gmail.com".freeze
  s.extra_rdoc_files = ["README.rdoc".freeze]
  s.files = ["README.rdoc".freeze]
  s.homepage = "http://github.com/joshbuddy/callsite".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Caller/backtrace parser with some useful utilities for manipulating the load path, and doing other relative things.".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.0.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 0.8.7"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 1.3.0"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.0.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 0.8.7"])
      s.add_dependency(%q<rspec>.freeze, ["~> 1.3.0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.0.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 0.8.7"])
    s.add_dependency(%q<rspec>.freeze, ["~> 1.3.0"])
  end
end

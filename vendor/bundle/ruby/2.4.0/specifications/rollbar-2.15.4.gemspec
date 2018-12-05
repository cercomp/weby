# -*- encoding: utf-8 -*-
# stub: rollbar 2.15.4 ruby lib

Gem::Specification.new do |s|
  s.name = "rollbar".freeze
  s.version = "2.15.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Rollbar, Inc.".freeze]
  s.date = "2017-09-19"
  s.description = "Easy and powerful exception tracking for Ruby".freeze
  s.email = ["support@rollbar.com".freeze]
  s.executables = ["rollbar-rails-runner".freeze]
  s.files = ["bin/rollbar-rails-runner".freeze]
  s.homepage = "https://rollbar.com".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Reports exceptions to Rollbar".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<multi_json>.freeze, [">= 0"])
    else
      s.add_dependency(%q<multi_json>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<multi_json>.freeze, [">= 0"])
  end
end

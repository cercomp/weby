# -*- encoding: utf-8 -*-
# stub: zeroclipboard-rails 0.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "zeroclipboard-rails".freeze
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Henrik Wenz".freeze, "Paul Jolly".freeze]
  s.date = "2016-06-18"
  s.description = "ZeroClipboard libary support for Rails".freeze
  s.email = ["handtrix@gmail.com".freeze]
  s.homepage = "https://github.com/zeroclipboard/zeroclipboard-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Adds the Javascript ZeroClipboard libary to Rails".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, [">= 3.1"])
    else
      s.add_dependency(%q<railties>.freeze, [">= 3.1"])
    end
  else
    s.add_dependency(%q<railties>.freeze, [">= 3.1"])
  end
end

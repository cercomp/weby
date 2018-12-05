# -*- encoding: utf-8 -*-
# stub: gretel 3.0.9 ruby lib

Gem::Specification.new do |s|
  s.name = "gretel".freeze
  s.version = "3.0.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Lasse Bunk".freeze]
  s.date = "2016-08-21"
  s.description = "Gretel is a Ruby on Rails plugin that makes it easy yet flexible to create breadcrumbs.".freeze
  s.email = ["lassebunk@gmail.com".freeze]
  s.homepage = "http://github.com/lassebunk/gretel".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Flexible Ruby on Rails breadcrumbs plugin.".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>.freeze, [">= 3.1.0"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rails>.freeze, [">= 3.1.0"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>.freeze, [">= 3.1.0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
  end
end

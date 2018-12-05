# -*- encoding: utf-8 -*-
# stub: gretel 3.0.9 ruby lib

Gem::Specification.new do |s|
  s.name = "gretel"
  s.version = "3.0.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Lasse Bunk"]
  s.date = "2016-08-21"
  s.description = "Gretel is a Ruby on Rails plugin that makes it easy yet flexible to create breadcrumbs."
  s.email = ["lassebunk@gmail.com"]
  s.homepage = "http://github.com/lassebunk/gretel"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Flexible Ruby on Rails breadcrumbs plugin."

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, [">= 3.1.0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
    else
      s.add_dependency(%q<rails>, [">= 3.1.0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, [">= 3.1.0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
  end
end

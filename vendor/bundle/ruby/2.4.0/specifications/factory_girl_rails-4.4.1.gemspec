# -*- encoding: utf-8 -*-
# stub: factory_girl_rails 4.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "factory_girl_rails".freeze
  s.version = "4.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Joe Ferris".freeze]
  s.date = "2014-02-26"
  s.description = "factory_girl_rails provides integration between\n    factory_girl and rails 3 (currently just automatic factory definition\n    loading)".freeze
  s.email = "jferris@thoughtbot.com".freeze
  s.homepage = "http://github.com/thoughtbot/factory_girl_rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.8".freeze
  s.summary = "factory_girl_rails provides integration between factory_girl and rails 3".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, [">= 3.0.0"])
      s.add_runtime_dependency(%q<factory_girl>.freeze, ["~> 4.4.0"])
      s.add_development_dependency(%q<appraisal>.freeze, ["~> 0.5.0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 2.11.0"])
      s.add_development_dependency(%q<cucumber>.freeze, ["~> 1.2.1"])
      s.add_development_dependency(%q<aruba>.freeze, ["~> 0.5.1"])
    else
      s.add_dependency(%q<railties>.freeze, [">= 3.0.0"])
      s.add_dependency(%q<factory_girl>.freeze, ["~> 4.4.0"])
      s.add_dependency(%q<appraisal>.freeze, ["~> 0.5.0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 2.11.0"])
      s.add_dependency(%q<cucumber>.freeze, ["~> 1.2.1"])
      s.add_dependency(%q<aruba>.freeze, ["~> 0.5.1"])
    end
  else
    s.add_dependency(%q<railties>.freeze, [">= 3.0.0"])
    s.add_dependency(%q<factory_girl>.freeze, ["~> 4.4.0"])
    s.add_dependency(%q<appraisal>.freeze, ["~> 0.5.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 2.11.0"])
    s.add_dependency(%q<cucumber>.freeze, ["~> 1.2.1"])
    s.add_dependency(%q<aruba>.freeze, ["~> 0.5.1"])
  end
end

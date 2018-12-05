# -*- encoding: utf-8 -*-
# stub: omniauth-shibboleth 1.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "omniauth-shibboleth".freeze
  s.version = "1.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Toyokazu Akiyama".freeze]
  s.date = "2017-08-28"
  s.description = "OmniAuth Shibboleth strategies for OmniAuth 1.x".freeze
  s.email = ["toyokazu@gmail.com".freeze]
  s.homepage = "".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.8".freeze
  s.summary = "OmniAuth Shibboleth strategies for OmniAuth 1.x".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<omniauth>.freeze, [">= 1.0.0"])
      s.add_development_dependency(%q<rack-test>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 2.8"])
    else
      s.add_dependency(%q<omniauth>.freeze, [">= 1.0.0"])
      s.add_dependency(%q<rack-test>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, [">= 2.8"])
    end
  else
    s.add_dependency(%q<omniauth>.freeze, [">= 1.0.0"])
    s.add_dependency(%q<rack-test>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 2.8"])
  end
end

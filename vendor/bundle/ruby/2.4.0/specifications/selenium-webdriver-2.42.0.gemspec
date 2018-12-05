# -*- encoding: utf-8 -*-
# stub: selenium-webdriver 2.42.0 ruby lib

Gem::Specification.new do |s|
  s.name = "selenium-webdriver".freeze
  s.version = "2.42.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jari Bakken".freeze]
  s.date = "2014-05-22"
  s.description = "WebDriver is a tool for writing automated tests of websites. It aims to mimic the behaviour of a real user, and as such interacts with the HTML of the application.".freeze
  s.email = "jari.bakken@gmail.com".freeze
  s.homepage = "http://selenium.googlecode.com".freeze
  s.licenses = ["Apache".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2".freeze)
  s.rubygems_version = "2.6.8".freeze
  s.summary = "The next generation developer focused tool for automated testing of webapps".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<multi_json>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<rubyzip>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<childprocess>.freeze, [">= 0.5.0"])
      s.add_runtime_dependency(%q<websocket>.freeze, ["~> 1.0.4"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 2.0"])
      s.add_development_dependency(%q<rack>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<ci_reporter>.freeze, ["~> 1.6.2"])
      s.add_development_dependency(%q<webmock>.freeze, ["~> 1.7.5"])
    else
      s.add_dependency(%q<multi_json>.freeze, ["~> 1.0"])
      s.add_dependency(%q<rubyzip>.freeze, ["~> 1.0"])
      s.add_dependency(%q<childprocess>.freeze, [">= 0.5.0"])
      s.add_dependency(%q<websocket>.freeze, ["~> 1.0.4"])
      s.add_dependency(%q<rspec>.freeze, ["~> 2.0"])
      s.add_dependency(%q<rack>.freeze, ["~> 1.0"])
      s.add_dependency(%q<ci_reporter>.freeze, ["~> 1.6.2"])
      s.add_dependency(%q<webmock>.freeze, ["~> 1.7.5"])
    end
  else
    s.add_dependency(%q<multi_json>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rubyzip>.freeze, ["~> 1.0"])
    s.add_dependency(%q<childprocess>.freeze, [">= 0.5.0"])
    s.add_dependency(%q<websocket>.freeze, ["~> 1.0.4"])
    s.add_dependency(%q<rspec>.freeze, ["~> 2.0"])
    s.add_dependency(%q<rack>.freeze, ["~> 1.0"])
    s.add_dependency(%q<ci_reporter>.freeze, ["~> 1.6.2"])
    s.add_dependency(%q<webmock>.freeze, ["~> 1.7.5"])
  end
end

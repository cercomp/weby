# -*- encoding: utf-8 -*-
# stub: uniform_notifier 1.10.0 ruby lib

Gem::Specification.new do |s|
  s.name = "uniform_notifier"
  s.version = "1.10.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Richard Huang"]
  s.date = "2016-01-06"
  s.description = "uniform notifier for rails logger, customized logger, javascript alert, javascript console, growl and xmpp"
  s.email = ["flyerhzm@gmail.com"]
  s.homepage = "http://rubygems.org/gems/uniform_notifier"
  s.licenses = ["MIT"]
  s.rubyforge_project = "uniform_notifier"
  s.rubygems_version = "2.2.2"
  s.summary = "uniform notifier for rails logger, customized logger, javascript alert, javascript console, growl and xmpp"

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<ruby-growl>, ["= 4.0"])
      s.add_development_dependency(%q<ruby_gntp>, ["= 0.3.4"])
      s.add_development_dependency(%q<xmpp4r>, ["= 0.5"])
      s.add_development_dependency(%q<slack-notifier>, [">= 1.0"])
      s.add_development_dependency(%q<rspec>, ["> 0"])
    else
      s.add_dependency(%q<ruby-growl>, ["= 4.0"])
      s.add_dependency(%q<ruby_gntp>, ["= 0.3.4"])
      s.add_dependency(%q<xmpp4r>, ["= 0.5"])
      s.add_dependency(%q<slack-notifier>, [">= 1.0"])
      s.add_dependency(%q<rspec>, ["> 0"])
    end
  else
    s.add_dependency(%q<ruby-growl>, ["= 4.0"])
    s.add_dependency(%q<ruby_gntp>, ["= 0.3.4"])
    s.add_dependency(%q<xmpp4r>, ["= 0.5"])
    s.add_dependency(%q<slack-notifier>, [">= 1.0"])
    s.add_dependency(%q<rspec>, ["> 0"])
  end
end

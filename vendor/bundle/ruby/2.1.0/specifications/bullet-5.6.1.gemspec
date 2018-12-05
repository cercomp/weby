# -*- encoding: utf-8 -*-
# stub: bullet 5.6.1 ruby lib

Gem::Specification.new do |s|
  s.name = "bullet"
  s.version = "5.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Richard Huang"]
  s.date = "2017-08-01"
  s.description = "help to kill N+1 queries and unused eager loading."
  s.email = ["flyerhzm@gmail.com"]
  s.homepage = "http://github.com/flyerhzm/bullet"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "help to kill N+1 queries and unused eager loading."

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0"])
      s.add_runtime_dependency(%q<uniform_notifier>, ["~> 1.10.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.0.0"])
      s.add_dependency(%q<uniform_notifier>, ["~> 1.10.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.0.0"])
    s.add_dependency(%q<uniform_notifier>, ["~> 1.10.0"])
  end
end

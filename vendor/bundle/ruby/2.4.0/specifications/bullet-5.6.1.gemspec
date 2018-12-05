# -*- encoding: utf-8 -*-
# stub: bullet 5.6.1 ruby lib

Gem::Specification.new do |s|
  s.name = "bullet".freeze
  s.version = "5.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Richard Huang".freeze]
  s.date = "2017-08-01"
  s.description = "help to kill N+1 queries and unused eager loading.".freeze
  s.email = ["flyerhzm@gmail.com".freeze]
  s.homepage = "http://github.com/flyerhzm/bullet".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.8".freeze
  s.summary = "help to kill N+1 queries and unused eager loading.".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 3.0.0"])
      s.add_runtime_dependency(%q<uniform_notifier>.freeze, ["~> 1.10.0"])
    else
      s.add_dependency(%q<activesupport>.freeze, [">= 3.0.0"])
      s.add_dependency(%q<uniform_notifier>.freeze, ["~> 1.10.0"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 3.0.0"])
    s.add_dependency(%q<uniform_notifier>.freeze, ["~> 1.10.0"])
  end
end

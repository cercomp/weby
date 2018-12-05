# -*- encoding: utf-8 -*-
# stub: shoulda-matchers 2.6.2 ruby lib

Gem::Specification.new do |s|
  s.name = "shoulda-matchers".freeze
  s.version = "2.6.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tammer Saleh".freeze, "Joe Ferris".freeze, "Ryan McGeary".freeze, "Dan Croak".freeze, "Matt Jankowski".freeze, "Stafford Brunk".freeze]
  s.date = "2014-07-18"
  s.description = "Making tests easy on the fingers and eyes".freeze
  s.email = "support@thoughtbot.com".freeze
  s.homepage = "http://thoughtbot.com/community/".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2".freeze)
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Making tests easy on the fingers and eyes".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 3.0.0"])
    else
      s.add_dependency(%q<activesupport>.freeze, [">= 3.0.0"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 3.0.0"])
  end
end

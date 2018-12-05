# -*- encoding: utf-8 -*-
# stub: non-stupid-digest-assets 1.0.9 ruby lib

Gem::Specification.new do |s|
  s.name = "non-stupid-digest-assets".freeze
  s.version = "1.0.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Alex Speller".freeze]
  s.date = "2016-11-15"
  s.description = "    Rails 4, much to everyone's annoyance, provides no option to generate both digest\n    and non-digest assets. Installing this gem automatically creates both digest and\n    non-digest assets which are useful for many reasons. See this issue for more details:\n    https://github.com/rails/sprockets-rails/issues/49\n".freeze
  s.email = ["alex@alexspeller.com".freeze]
  s.homepage = "http://github.com/alexspeller/non-stupid-digest-assets".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0".freeze)
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Fix the Rails 4 asset pipeline to generate non-digest along with digest assets".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sprockets>.freeze, [">= 2.0"])
    else
      s.add_dependency(%q<sprockets>.freeze, [">= 2.0"])
    end
  else
    s.add_dependency(%q<sprockets>.freeze, [">= 2.0"])
  end
end

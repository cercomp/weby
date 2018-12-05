# -*- encoding: utf-8 -*-
# stub: bootstrap-daterangepicker-rails 0.1.5 ruby lib

Gem::Specification.new do |s|
  s.name = "bootstrap-daterangepicker-rails"
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Dan Grossman", "Jordan Brock"]
  s.date = "2016-08-08"
  s.description = "Rails 4.1.x plugin to allow for the easy use of Dan Grossman's Bootstrap DateRangePicker"
  s.email = "jordan@brock.id.au"
  s.homepage = "http://github.com/jordanbrock/bootstrap-daterangepicker-rails"
  s.rubygems_version = "2.2.2"
  s.summary = "Rails 4.1x plugin to allow for the easy use of Dan Grossman's Bootstrap DateRangePicker"

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>, ["< 5.1", ">= 4.0"])
      s.add_development_dependency(%q<test-unit>, ["~> 2.2"])
    else
      s.add_dependency(%q<railties>, ["< 5.1", ">= 4.0"])
      s.add_dependency(%q<test-unit>, ["~> 2.2"])
    end
  else
    s.add_dependency(%q<railties>, ["< 5.1", ">= 4.0"])
    s.add_dependency(%q<test-unit>, ["~> 2.2"])
  end
end

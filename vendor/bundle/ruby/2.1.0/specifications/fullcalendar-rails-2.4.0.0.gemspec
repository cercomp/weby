# -*- encoding: utf-8 -*-
# stub: fullcalendar-rails 2.4.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "fullcalendar-rails"
  s.version = "2.4.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["bokmann", "gr8bit"]
  s.date = "2015-10-09"
  s.description = "FullCalendar is a fantastic jQuery plugin that gives you an event calendar with tons of great AJAX wizardry, including drag and drop of events.  I like having managed pipeline assets, so I gemified it."
  s.email = ["dbock@codesherpas.com", "niklas@bichinger.de"]
  s.homepage = "https://github.com/bokmann/fullcalendar-rails"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "A simple asset pipeline bundling for Ruby on Rails of the FullCalendar jQuery plugin."

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<jquery-rails>, ["< 5.0.0", ">= 3.1.1"])
      s.add_runtime_dependency(%q<momentjs-rails>, [">= 2.9.0"])
      s.add_development_dependency(%q<rake>, ["~> 0"])
    else
      s.add_dependency(%q<jquery-rails>, ["< 5.0.0", ">= 3.1.1"])
      s.add_dependency(%q<momentjs-rails>, [">= 2.9.0"])
      s.add_dependency(%q<rake>, ["~> 0"])
    end
  else
    s.add_dependency(%q<jquery-rails>, ["< 5.0.0", ">= 3.1.1"])
    s.add_dependency(%q<momentjs-rails>, [">= 2.9.0"])
    s.add_dependency(%q<rake>, ["~> 0"])
  end
end

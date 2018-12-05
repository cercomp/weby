# -*- encoding: utf-8 -*-
# stub: rails-settings-cached 0.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rails-settings-cached".freeze
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Squeegy".freeze, "Georg Ledermann".freeze, "100hz".freeze, "Jason Lee".freeze]
  s.date = "2014-05-12"
  s.email = "huacnlee@gmail.com".freeze
  s.homepage = "https://github.com/huacnlee/rails-settings-cached".freeze
  s.rubygems_version = "2.6.8".freeze
  s.summary = "This is imporved from rails-settings, added caching. Settings is a plugin that makes managing a table of global key, value pairs easy. Think of it like a global Hash stored in you database, that uses simple ActiveRecord like methods for manipulation.  Keep track of any global setting that you dont want to hard code into your rails app.  You can store any kind of object.  Strings, numbers, arrays, or any object. Ported to Rails 3!".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>.freeze, [">= 4.0.0"])
    else
      s.add_dependency(%q<rails>.freeze, [">= 4.0.0"])
    end
  else
    s.add_dependency(%q<rails>.freeze, [">= 4.0.0"])
  end
end

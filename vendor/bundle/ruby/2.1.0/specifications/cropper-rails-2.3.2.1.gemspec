# -*- encoding: utf-8 -*-
# stub: cropper-rails 2.3.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "cropper-rails"
  s.version = "2.3.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Cristian Bica"]
  s.bindir = "exe"
  s.date = "2016-06-27"
  s.description = "This gem wraps fengyuanchen's cropper to be used inside Rails applications."
  s.email = ["cristian.bica@gmail.com"]
  s.homepage = "https://github.com/cristianbica/cropper-rails"
  s.rubygems_version = "2.2.2"
  s.summary = "Fengyuanchen's Cropper with Rails assets pipeline."

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>, [">= 3.1.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.10"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
    else
      s.add_dependency(%q<railties>, [">= 3.1.0"])
      s.add_dependency(%q<bundler>, ["~> 1.10"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
    end
  else
    s.add_dependency(%q<railties>, [">= 3.1.0"])
    s.add_dependency(%q<bundler>, ["~> 1.10"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
  end
end

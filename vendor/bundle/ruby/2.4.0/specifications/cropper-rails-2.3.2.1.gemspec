# -*- encoding: utf-8 -*-
# stub: cropper-rails 2.3.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "cropper-rails".freeze
  s.version = "2.3.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Cristian Bica".freeze]
  s.bindir = "exe".freeze
  s.date = "2016-06-27"
  s.description = "This gem wraps fengyuanchen's cropper to be used inside Rails applications.".freeze
  s.email = ["cristian.bica@gmail.com".freeze]
  s.homepage = "https://github.com/cristianbica/cropper-rails".freeze
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Fengyuanchen's Cropper with Rails assets pipeline.".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, [">= 3.1.0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.10"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    else
      s.add_dependency(%q<railties>.freeze, [">= 3.1.0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.10"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    end
  else
    s.add_dependency(%q<railties>.freeze, [">= 3.1.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.10"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
  end
end

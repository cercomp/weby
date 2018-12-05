# -*- encoding: utf-8 -*-
# stub: debug_inspector 0.0.3 ruby lib
# stub: ext/debug_inspector/extconf.rb

Gem::Specification.new do |s|
  s.name = "debug_inspector"
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["John Mair (banisterfiend)"]
  s.date = "2017-05-08"
  s.description = "A Ruby wrapper for the MRI 2.0 debug_inspector API"
  s.email = ["jrmair@gmail.com"]
  s.extensions = ["ext/debug_inspector/extconf.rb"]
  s.files = ["ext/debug_inspector/extconf.rb"]
  s.homepage = "https://github.com/banister/debug_inspector"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "A Ruby wrapper for the MRI 2.0 debug_inspector API"

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, [">= 5"])
    else
      s.add_dependency(%q<minitest>, [">= 5"])
    end
  else
    s.add_dependency(%q<minitest>, [">= 5"])
  end
end

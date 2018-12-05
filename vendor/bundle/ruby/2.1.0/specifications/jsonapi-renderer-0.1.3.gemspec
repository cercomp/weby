# -*- encoding: utf-8 -*-
# stub: jsonapi-renderer 0.1.3 ruby lib

Gem::Specification.new do |s|
  s.name = "jsonapi-renderer"
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Lucas Hosseini"]
  s.date = "2017-07-12"
  s.description = "Efficiently render JSON API documents."
  s.email = "lucas.hosseini@gmail.com"
  s.homepage = "https://github.com/jsonapi-rb/jsonapi-renderer"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Render JSONAPI documents."

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, ["~> 11.3"])
      s.add_development_dependency(%q<rspec>, ["~> 3.5"])
      s.add_development_dependency(%q<codecov>, ["~> 0.1"])
    else
      s.add_dependency(%q<rake>, ["~> 11.3"])
      s.add_dependency(%q<rspec>, ["~> 3.5"])
      s.add_dependency(%q<codecov>, ["~> 0.1"])
    end
  else
    s.add_dependency(%q<rake>, ["~> 11.3"])
    s.add_dependency(%q<rspec>, ["~> 3.5"])
    s.add_dependency(%q<codecov>, ["~> 0.1"])
  end
end

# -*- encoding: utf-8 -*-
# stub: websocket 1.0.7 ruby lib

Gem::Specification.new do |s|
  s.name = "websocket".freeze
  s.version = "1.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Bernard Potocki".freeze]
  s.date = "2013-01-27"
  s.description = "Universal Ruby library to handle WebSocket protocol".freeze
  s.email = ["bernard.potocki@imanel.org".freeze]
  s.homepage = "http://github.com/imanel/websocket-ruby".freeze
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Universal Ruby library to handle WebSocket protocol".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>.freeze, ["~> 2.11"])
    else
      s.add_dependency(%q<rspec>.freeze, ["~> 2.11"])
    end
  else
    s.add_dependency(%q<rspec>.freeze, ["~> 2.11"])
  end
end

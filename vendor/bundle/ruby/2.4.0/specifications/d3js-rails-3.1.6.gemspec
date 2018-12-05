# -*- encoding: utf-8 -*-
# stub: d3js-rails 3.1.6 ruby lib

Gem::Specification.new do |s|
  s.name = "d3js-rails".freeze
  s.version = "3.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Eric Milford".freeze, "Ryan Glover".freeze]
  s.date = "2013-05-15"
  s.description = "D3.js is a JavaScript library for manipulating documents based on data. D3 helps you bring data to life using HTML, SVG and CSS. D3\u2019s emphasis on web standards gives you the full capabilities of modern browsers without tying yourself to a proprietary framework, combining powerful visualization components and a data-driven approach to DOM manipulation.".freeze
  s.email = ["ericmilford@gmail.com".freeze, "ersatzryan@gmail.com".freeze]
  s.homepage = "http://github.com/emilford/d3js-rails".freeze
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Gemified d3.v2.js asset for Rails".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, ["< 5.0", ">= 3.0"])
    else
      s.add_dependency(%q<railties>.freeze, ["< 5.0", ">= 3.0"])
    end
  else
    s.add_dependency(%q<railties>.freeze, ["< 5.0", ">= 3.0"])
  end
end

# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'd3js-rails/version'

Gem::Specification.new do |gem|
  gem.name          = "d3js-rails"
  gem.version       = D3js::Rails::VERSION
  gem.authors       = ["Eric Milford", "Ryan Glover"]
  gem.email         = ["ericmilford@gmail.com", "ersatzryan@gmail.com"]
  gem.description   = %q{D3.js is a JavaScript library for manipulating documents based on data. D3 helps you bring data to life using HTML, SVG and CSS. D3’s emphasis on web standards gives you the full capabilities of modern browsers without tying yourself to a proprietary framework, combining powerful visualization components and a data-driven approach to DOM manipulation.}
  gem.summary       = %q{Gemified d3.v2.js asset for Rails}
  gem.homepage      = "http://github.com/emilford/d3js-rails"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "railties", ">= 3.0", "< 5.0"
end

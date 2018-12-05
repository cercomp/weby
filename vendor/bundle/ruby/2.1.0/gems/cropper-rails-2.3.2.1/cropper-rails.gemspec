# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cropper/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "cropper-rails"
  spec.version       = Cropper::Rails::VERSION
  spec.authors       = ["Cristian Bica"]
  spec.email         = ["cristian.bica@gmail.com"]

  spec.summary       = %q{Fengyuanchen's Cropper with Rails assets pipeline.}
  spec.description   = %q{This gem wraps fengyuanchen's cropper to be used inside Rails applications.}
  spec.homepage      = "https://github.com/cristianbica/cropper-rails"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", ">= 3.1.0"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end

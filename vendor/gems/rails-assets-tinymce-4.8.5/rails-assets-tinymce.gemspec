# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails-assets-tinymce/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-assets-tinymce"
  spec.version       = RailsAssetsTinymce::VERSION
  spec.authors       = ["rails-assets.org"]
  spec.description   = "Web based JavaScript HTML WYSIWYG editor control."
  spec.summary       = "Web based JavaScript HTML WYSIWYG editor control."
  spec.homepage      = "http://www.tinymce.com/"
  spec.license       = "LGPL-2.1"

  spec.files         = `find ./* -type f | cut -b 3-`.split($/)
  spec.require_paths = ["lib"]


    spec.post_install_message = "This component doesn't define main assets in bower.json.\nPlease open new pull request in component's repository:\nhttp://www.tinymce.com/"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end

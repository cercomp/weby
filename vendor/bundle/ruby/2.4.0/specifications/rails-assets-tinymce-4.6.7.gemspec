# -*- encoding: utf-8 -*-
# stub: rails-assets-tinymce 4.6.7 ruby lib

Gem::Specification.new do |s|
  s.name = "rails-assets-tinymce".freeze
  s.version = "4.6.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["rails-assets.org".freeze]
  s.date = "2017-09-19"
  s.description = "Web based JavaScript HTML WYSIWYG editor control.".freeze
  s.homepage = "http://www.tinymce.com/".freeze
  s.licenses = ["LGPL-2.1".freeze]
  s.post_install_message = "This component doesn't define main assets in bower.json.\nPlease open new pull request in component's repository:\nhttp://www.tinymce.com/".freeze
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Web based JavaScript HTML WYSIWYG editor control.".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end

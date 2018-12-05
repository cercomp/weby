# -*- encoding: utf-8 -*-
# stub: font-awesome-rails 4.7.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "font-awesome-rails".freeze
  s.version = "4.7.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["bokmann".freeze]
  s.date = "2017-05-01"
  s.description = "I like font-awesome. I like the asset pipeline. I like semantic versioning. If you do too, you're welcome.".freeze
  s.email = ["dbock@codesherpas.com".freeze]
  s.homepage = "https://github.com/bokmann/font-awesome-rails".freeze
  s.licenses = ["MIT".freeze, "SIL Open Font License".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubygems_version = "2.6.8".freeze
  s.summary = "an asset gemification of the font-awesome icon font library".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, ["< 5.2", ">= 3.2"])
      s.add_development_dependency(%q<activesupport>.freeze, [">= 0"])
      s.add_development_dependency(%q<sass-rails>.freeze, [">= 0"])
    else
      s.add_dependency(%q<railties>.freeze, ["< 5.2", ">= 3.2"])
      s.add_dependency(%q<activesupport>.freeze, [">= 0"])
      s.add_dependency(%q<sass-rails>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<railties>.freeze, ["< 5.2", ">= 3.2"])
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<sass-rails>.freeze, [">= 0"])
  end
end

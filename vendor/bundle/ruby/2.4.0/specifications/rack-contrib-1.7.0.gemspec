# -*- encoding: utf-8 -*-
# stub: rack-contrib 1.7.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rack-contrib".freeze
  s.version = "1.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["rack-devel".freeze]
  s.date = "2017-10-01"
  s.description = "Contributed Rack Middleware and Utilities".freeze
  s.email = "rack-devel@googlegroups.com".freeze
  s.extra_rdoc_files = ["README.md".freeze, "COPYING".freeze]
  s.files = ["COPYING".freeze, "README.md".freeze]
  s.homepage = "http://github.com/rack/rack-contrib/".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--line-numbers".freeze, "--inline-source".freeze, "--title".freeze, "rack-contrib".freeze, "--main".freeze, "README".freeze]
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Contributed Rack Middleware and Utilities".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<git-version-bump>.freeze, ["~> 0.15"])
      s.add_development_dependency(%q<github-release>.freeze, ["~> 0.1"])
      s.add_development_dependency(%q<i18n>.freeze, [">= 0.5.2", "~> 0.5"])
      s.add_development_dependency(%q<json>.freeze, [">= 1.8.5", "~> 1.8"])
      s.add_development_dependency(%q<mime-types>.freeze, ["< 3"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.6"])
      s.add_development_dependency(%q<minitest-hooks>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<mail>.freeze, ["~> 2.3"])
      s.add_development_dependency(%q<nbio-csshttprequest>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 10.4.2", "~> 10.4"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 3.12"])
      s.add_development_dependency(%q<ruby-prof>.freeze, ["~> 0.13.0"])
    else
      s.add_dependency(%q<rack>.freeze, ["~> 1.4"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
      s.add_dependency(%q<git-version-bump>.freeze, ["~> 0.15"])
      s.add_dependency(%q<github-release>.freeze, ["~> 0.1"])
      s.add_dependency(%q<i18n>.freeze, [">= 0.5.2", "~> 0.5"])
      s.add_dependency(%q<json>.freeze, [">= 1.8.5", "~> 1.8"])
      s.add_dependency(%q<mime-types>.freeze, ["< 3"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.6"])
      s.add_dependency(%q<minitest-hooks>.freeze, ["~> 1.0"])
      s.add_dependency(%q<mail>.freeze, ["~> 2.3"])
      s.add_dependency(%q<nbio-csshttprequest>.freeze, ["~> 1.0"])
      s.add_dependency(%q<rake>.freeze, [">= 10.4.2", "~> 10.4"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 3.12"])
      s.add_dependency(%q<ruby-prof>.freeze, ["~> 0.13.0"])
    end
  else
    s.add_dependency(%q<rack>.freeze, ["~> 1.4"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
    s.add_dependency(%q<git-version-bump>.freeze, ["~> 0.15"])
    s.add_dependency(%q<github-release>.freeze, ["~> 0.1"])
    s.add_dependency(%q<i18n>.freeze, [">= 0.5.2", "~> 0.5"])
    s.add_dependency(%q<json>.freeze, [">= 1.8.5", "~> 1.8"])
    s.add_dependency(%q<mime-types>.freeze, ["< 3"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.6"])
    s.add_dependency(%q<minitest-hooks>.freeze, ["~> 1.0"])
    s.add_dependency(%q<mail>.freeze, ["~> 2.3"])
    s.add_dependency(%q<nbio-csshttprequest>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rake>.freeze, [">= 10.4.2", "~> 10.4"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 3.12"])
    s.add_dependency(%q<ruby-prof>.freeze, ["~> 0.13.0"])
  end
end

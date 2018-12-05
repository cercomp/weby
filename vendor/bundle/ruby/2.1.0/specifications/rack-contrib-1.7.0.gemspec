# -*- encoding: utf-8 -*-
# stub: rack-contrib 1.7.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rack-contrib"
  s.version = "1.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["rack-devel"]
  s.date = "2017-10-01"
  s.description = "Contributed Rack Middleware and Utilities"
  s.email = "rack-devel@googlegroups.com"
  s.extra_rdoc_files = ["README.md", "COPYING"]
  s.files = ["COPYING", "README.md"]
  s.homepage = "http://github.com/rack/rack-contrib/"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "rack-contrib", "--main", "README"]
  s.rubygems_version = "2.2.2"
  s.summary = "Contributed Rack Middleware and Utilities"

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, ["~> 1.4"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<git-version-bump>, ["~> 0.15"])
      s.add_development_dependency(%q<github-release>, ["~> 0.1"])
      s.add_development_dependency(%q<i18n>, [">= 0.5.2", "~> 0.5"])
      s.add_development_dependency(%q<json>, [">= 1.8.5", "~> 1.8"])
      s.add_development_dependency(%q<mime-types>, ["< 3"])
      s.add_development_dependency(%q<minitest>, ["~> 5.6"])
      s.add_development_dependency(%q<minitest-hooks>, ["~> 1.0"])
      s.add_development_dependency(%q<mail>, ["~> 2.3"])
      s.add_development_dependency(%q<nbio-csshttprequest>, ["~> 1.0"])
      s.add_development_dependency(%q<rake>, [">= 10.4.2", "~> 10.4"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<ruby-prof>, ["~> 0.13.0"])
    else
      s.add_dependency(%q<rack>, ["~> 1.4"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<git-version-bump>, ["~> 0.15"])
      s.add_dependency(%q<github-release>, ["~> 0.1"])
      s.add_dependency(%q<i18n>, [">= 0.5.2", "~> 0.5"])
      s.add_dependency(%q<json>, [">= 1.8.5", "~> 1.8"])
      s.add_dependency(%q<mime-types>, ["< 3"])
      s.add_dependency(%q<minitest>, ["~> 5.6"])
      s.add_dependency(%q<minitest-hooks>, ["~> 1.0"])
      s.add_dependency(%q<mail>, ["~> 2.3"])
      s.add_dependency(%q<nbio-csshttprequest>, ["~> 1.0"])
      s.add_dependency(%q<rake>, [">= 10.4.2", "~> 10.4"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<ruby-prof>, ["~> 0.13.0"])
    end
  else
    s.add_dependency(%q<rack>, ["~> 1.4"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<git-version-bump>, ["~> 0.15"])
    s.add_dependency(%q<github-release>, ["~> 0.1"])
    s.add_dependency(%q<i18n>, [">= 0.5.2", "~> 0.5"])
    s.add_dependency(%q<json>, [">= 1.8.5", "~> 1.8"])
    s.add_dependency(%q<mime-types>, ["< 3"])
    s.add_dependency(%q<minitest>, ["~> 5.6"])
    s.add_dependency(%q<minitest-hooks>, ["~> 1.0"])
    s.add_dependency(%q<mail>, ["~> 2.3"])
    s.add_dependency(%q<nbio-csshttprequest>, ["~> 1.0"])
    s.add_dependency(%q<rake>, [">= 10.4.2", "~> 10.4"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<ruby-prof>, ["~> 0.13.0"])
  end
end

# -*- encoding: utf-8 -*-
# stub: select2-rails 3.5.10 ruby lib

Gem::Specification.new do |s|
  s.name = "select2-rails".freeze
  s.version = "3.5.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Rogerio Medeiros".freeze, "Pedro Nascimento".freeze]
  s.date = "2016-03-02"
  s.description = "Select2 is a jQuery based replacement for select boxes. It supports searching, remote data sets, and infinite scrolling of results. This gem integrates Select2 with Rails asset pipeline for easy of use.".freeze
  s.email = ["argerim@gmail.com".freeze, "pnascimento@gmail.com".freeze]
  s.homepage = "https://github.com/argerim/select2-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Integrate Select2 javascript library with Rails asset pipeline".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<thor>.freeze, ["~> 0.14"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<rails>.freeze, [">= 3.0"])
      s.add_development_dependency(%q<httpclient>.freeze, ["~> 2.2"])
    else
      s.add_dependency(%q<thor>.freeze, ["~> 0.14"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
      s.add_dependency(%q<rails>.freeze, [">= 3.0"])
      s.add_dependency(%q<httpclient>.freeze, ["~> 2.2"])
    end
  else
    s.add_dependency(%q<thor>.freeze, ["~> 0.14"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rails>.freeze, [">= 3.0"])
    s.add_dependency(%q<httpclient>.freeze, ["~> 2.2"])
  end
end

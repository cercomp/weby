# -*- encoding: utf-8 -*-
# stub: active_model_serializers 0.10.6 ruby lib

Gem::Specification.new do |s|
  s.name = "active_model_serializers"
  s.version = "0.10.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Steve Klabnik"]
  s.date = "2017-05-01"
  s.description = "ActiveModel::Serializers allows you to generate your JSON in an object-oriented and convention-driven manner."
  s.email = ["steve@steveklabnik.com"]
  s.homepage = "https://github.com/rails-api/active_model_serializers"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1")
  s.rubygems_version = "2.2.2"
  s.summary = "Conventions-based JSON generation for Rails."

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activemodel>, ["< 6", ">= 4.1"])
      s.add_runtime_dependency(%q<actionpack>, ["< 6", ">= 4.1"])
      s.add_development_dependency(%q<railties>, ["< 6", ">= 4.1"])
      s.add_runtime_dependency(%q<jsonapi-renderer>, ["< 0.2", ">= 0.1.1.beta1"])
      s.add_runtime_dependency(%q<case_transform>, [">= 0.2"])
      s.add_development_dependency(%q<activerecord>, ["< 6", ">= 4.1"])
      s.add_development_dependency(%q<kaminari>, ["~> 0.16.3"])
      s.add_development_dependency(%q<will_paginate>, [">= 3.0.7", "~> 3.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.6"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.11"])
      s.add_development_dependency(%q<timecop>, ["~> 0.7"])
      s.add_development_dependency(%q<grape>, ["< 0.19.1", ">= 0.13"])
      s.add_development_dependency(%q<json_schema>, [">= 0"])
      s.add_development_dependency(%q<rake>, ["< 12.0", ">= 10.0"])
    else
      s.add_dependency(%q<activemodel>, ["< 6", ">= 4.1"])
      s.add_dependency(%q<actionpack>, ["< 6", ">= 4.1"])
      s.add_dependency(%q<railties>, ["< 6", ">= 4.1"])
      s.add_dependency(%q<jsonapi-renderer>, ["< 0.2", ">= 0.1.1.beta1"])
      s.add_dependency(%q<case_transform>, [">= 0.2"])
      s.add_dependency(%q<activerecord>, ["< 6", ">= 4.1"])
      s.add_dependency(%q<kaminari>, ["~> 0.16.3"])
      s.add_dependency(%q<will_paginate>, [">= 3.0.7", "~> 3.0"])
      s.add_dependency(%q<bundler>, ["~> 1.6"])
      s.add_dependency(%q<simplecov>, ["~> 0.11"])
      s.add_dependency(%q<timecop>, ["~> 0.7"])
      s.add_dependency(%q<grape>, ["< 0.19.1", ">= 0.13"])
      s.add_dependency(%q<json_schema>, [">= 0"])
      s.add_dependency(%q<rake>, ["< 12.0", ">= 10.0"])
    end
  else
    s.add_dependency(%q<activemodel>, ["< 6", ">= 4.1"])
    s.add_dependency(%q<actionpack>, ["< 6", ">= 4.1"])
    s.add_dependency(%q<railties>, ["< 6", ">= 4.1"])
    s.add_dependency(%q<jsonapi-renderer>, ["< 0.2", ">= 0.1.1.beta1"])
    s.add_dependency(%q<case_transform>, [">= 0.2"])
    s.add_dependency(%q<activerecord>, ["< 6", ">= 4.1"])
    s.add_dependency(%q<kaminari>, ["~> 0.16.3"])
    s.add_dependency(%q<will_paginate>, [">= 3.0.7", "~> 3.0"])
    s.add_dependency(%q<bundler>, ["~> 1.6"])
    s.add_dependency(%q<simplecov>, ["~> 0.11"])
    s.add_dependency(%q<timecop>, ["~> 0.7"])
    s.add_dependency(%q<grape>, ["< 0.19.1", ">= 0.13"])
    s.add_dependency(%q<json_schema>, [">= 0"])
    s.add_dependency(%q<rake>, ["< 12.0", ">= 10.0"])
  end
end

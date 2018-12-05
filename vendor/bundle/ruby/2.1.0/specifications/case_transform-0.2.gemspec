# -*- encoding: utf-8 -*-
# stub: case_transform 0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "case_transform"
  s.version = "0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["L. Preston Sego III", "Ben Mills"]
  s.date = "2016-09-22"
  s.description = "Extraction of the key_transform abilities of ActiveModelSerializers"
  s.email = "LPSego3+dev@gmail.com"
  s.homepage = "https://github.com/NullVoxPopuli/case_transform"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0")
  s.rubygems_version = "2.2.2"
  s.summary = "CaseTransform-0.2"

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rubocop>, [">= 0"])
      s.add_development_dependency(%q<codeclimate-test-reporter>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<awesome_print>, [">= 0"])
      s.add_development_dependency(%q<pry-byebug>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rubocop>, [">= 0"])
      s.add_dependency(%q<codeclimate-test-reporter>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<awesome_print>, [">= 0"])
      s.add_dependency(%q<pry-byebug>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rubocop>, [">= 0"])
    s.add_dependency(%q<codeclimate-test-reporter>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<awesome_print>, [">= 0"])
    s.add_dependency(%q<pry-byebug>, [">= 0"])
  end
end

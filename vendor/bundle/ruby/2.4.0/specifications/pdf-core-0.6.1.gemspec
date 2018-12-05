# -*- encoding: utf-8 -*-
# stub: pdf-core 0.6.1 ruby lib

Gem::Specification.new do |s|
  s.name = "pdf-core".freeze
  s.version = "0.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Gregory Brown".freeze, "Brad Ediger".freeze, "Daniel Nelson".freeze, "Jonathan Greenberg".freeze, "James Healy".freeze]
  s.date = "2016-02-21"
  s.description = "PDF::Core is used by Prawn to render PDF documents".freeze
  s.email = ["gregory.t.brown@gmail.com".freeze, "brad@bradediger.com".freeze, "dnelson@bluejade.com".freeze, "greenberg@entryway.net".freeze, "jimmy@deefa.com".freeze]
  s.homepage = "http://prawn.majesticseacreature.com".freeze
  s.licenses = ["PRAWN".freeze, "GPL-2.0".freeze, "GPL-3.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubyforge_project = "prawn".freeze
  s.rubygems_version = "2.6.8".freeze
  s.summary = "PDF::Core is used by Prawn to render PDF documents".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<pdf-reader>.freeze, ["~> 1.2"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<pdf-inspector>.freeze, ["~> 1.1.0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<pdf-reader>.freeze, ["~> 1.2"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<pdf-inspector>.freeze, ["~> 1.1.0"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<pdf-reader>.freeze, ["~> 1.2"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<pdf-inspector>.freeze, ["~> 1.1.0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end

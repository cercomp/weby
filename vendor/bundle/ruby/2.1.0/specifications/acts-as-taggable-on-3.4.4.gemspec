# -*- encoding: utf-8 -*-
# stub: acts-as-taggable-on 3.4.4 ruby lib

Gem::Specification.new do |s|
  s.name = "acts-as-taggable-on"
  s.version = "3.4.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Michael Bleigh", "Joost Baaij"]
  s.date = "2015-02-11"
  s.description = "With ActsAsTaggableOn, you can tag a single model on several contexts, such as skills, interests, and awards. It also provides other advanced functionality."
  s.email = ["michael@intridea.com", "joost@spacebabies.nl"]
  s.homepage = "https://github.com/mbleigh/acts-as-taggable-on"
  s.licenses = ["MIT"]
  s.post_install_message = "When upgrading\n\nRe-run the migrations generator\n\n    rake acts_as_taggable_on_engine:install:migrations\n\nIt will create any new migrations and skip existing ones"
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.2.2"
  s.summary = "Advanced tagging for Rails."

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, ["< 5", ">= 3.2"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<mysql2>, ["~> 0.3.7"])
      s.add_development_dependency(%q<pg>, [">= 0"])
      s.add_development_dependency(%q<rspec-rails>, [">= 0"])
      s.add_development_dependency(%q<rspec-its>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<barrier>, [">= 0"])
      s.add_development_dependency(%q<database_cleaner>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, ["< 5", ">= 3.2"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<mysql2>, ["~> 0.3.7"])
      s.add_dependency(%q<pg>, [">= 0"])
      s.add_dependency(%q<rspec-rails>, [">= 0"])
      s.add_dependency(%q<rspec-its>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<barrier>, [">= 0"])
      s.add_dependency(%q<database_cleaner>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, ["< 5", ">= 3.2"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<mysql2>, ["~> 0.3.7"])
    s.add_dependency(%q<pg>, [">= 0"])
    s.add_dependency(%q<rspec-rails>, [">= 0"])
    s.add_dependency(%q<rspec-its>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<barrier>, [">= 0"])
    s.add_dependency(%q<database_cleaner>, [">= 0"])
  end
end

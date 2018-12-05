# -*- encoding: utf-8 -*-
# stub: net-ldap 0.16.1 ruby lib

Gem::Specification.new do |s|
  s.name = "net-ldap"
  s.version = "0.16.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Francis Cianfrocca", "Emiel van de Laar", "Rory O'Connell", "Kaspar Schiess", "Austin Ziegler", "Michael Schaarschmidt"]
  s.date = "2017-10-31"
  s.description = "Net::LDAP for Ruby (also called net-ldap) implements client access for the\nLightweight Directory Access Protocol (LDAP), an IETF standard protocol for\naccessing distributed directory services. Net::LDAP is written completely in\nRuby with no external dependencies. It supports most LDAP client features and a\nsubset of server features as well.\n\nNet::LDAP has been tested against modern popular LDAP servers including\nOpenLDAP and Active Directory. The current release is mostly compliant with\nearlier versions of the IETF LDAP RFCs (2251-2256, 2829-2830, 3377, and 3771).\nOur roadmap for Net::LDAP 1.0 is to gain full <em>client</em> compliance with\nthe most recent LDAP RFCs (4510-4519, plutions of 4520-4532)."
  s.email = ["blackhedd@rubyforge.org", "gemiel@gmail.com", "rory.ocon@gmail.com", "kaspar.schiess@absurd.li", "austin@rubyforge.org"]
  s.extra_rdoc_files = ["Contributors.rdoc", "Hacking.rdoc", "History.rdoc", "License.rdoc", "README.rdoc"]
  s.files = ["Contributors.rdoc", "Hacking.rdoc", "History.rdoc", "License.rdoc", "README.rdoc"]
  s.homepage = "http://github.com/ruby-ldap/ruby-net-ldap"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0")
  s.rubygems_version = "2.2.2"
  s.summary = "Net::LDAP for Ruby (also called net-ldap) implements client access for the Lightweight Directory Access Protocol (LDAP), an IETF standard protocol for accessing distributed directory services"

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<flexmock>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<rubocop>, ["~> 0.42.0"])
      s.add_development_dependency(%q<test-unit>, [">= 0"])
      s.add_development_dependency(%q<byebug>, [">= 0"])
    else
      s.add_dependency(%q<flexmock>, ["~> 1.3"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<rubocop>, ["~> 0.42.0"])
      s.add_dependency(%q<test-unit>, [">= 0"])
      s.add_dependency(%q<byebug>, [">= 0"])
    end
  else
    s.add_dependency(%q<flexmock>, ["~> 1.3"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<rubocop>, ["~> 0.42.0"])
    s.add_dependency(%q<test-unit>, [">= 0"])
    s.add_dependency(%q<byebug>, [">= 0"])
  end
end

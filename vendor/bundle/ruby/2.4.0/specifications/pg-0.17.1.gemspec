# -*- encoding: utf-8 -*-
# stub: pg 0.17.1 ruby lib
# stub: ext/extconf.rb

Gem::Specification.new do |s|
  s.name = "pg".freeze
  s.version = "0.17.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze, "Lars Kanis".freeze]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDbDCCAlSgAwIBAgIBATANBgkqhkiG9w0BAQUFADA+MQwwCgYDVQQDDANnZWQx\nGTAXBgoJkiaJk/IsZAEZFglGYWVyaWVNVUQxEzARBgoJkiaJk/IsZAEZFgNvcmcw\nHhcNMTMwMjI3MTY0ODU4WhcNMTQwMjI3MTY0ODU4WjA+MQwwCgYDVQQDDANnZWQx\nGTAXBgoJkiaJk/IsZAEZFglGYWVyaWVNVUQxEzARBgoJkiaJk/IsZAEZFgNvcmcw\nggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDb92mkyYwuGBg1oRxt2tkH\n+Uo3LAsaL/APBfSLzy8o3+B3AUHKCjMUaVeBoZdWtMHB75X3VQlvXfZMyBxj59Vo\ncDthr3zdao4HnyrzAIQf7BO5Y8KBwVD+yyXCD/N65TTwqsQnO3ie7U5/9ut1rnNr\nOkOzAscMwkfQxBkXDzjvAWa6UF4c5c9kR/T79iA21kDx9+bUMentU59aCJtUcbxa\n7kcKJhPEYsk4OdxR9q2dphNMFDQsIdRO8rywX5FRHvcb+qnXC17RvxLHtOjysPtp\nEWsYoZMxyCDJpUqbwoeiM+tAHoz2ABMv3Ahie3Qeb6+MZNAtMmaWfBx3dg2u+/WN\nAgMBAAGjdTBzMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdDgQWBBSZ0hCV\nqoHr122fGKelqffzEQBhszAcBgNVHREEFTATgRFnZWRARmFlcmllTVVELm9yZzAc\nBgNVHRIEFTATgRFnZWRARmFlcmllTVVELm9yZzANBgkqhkiG9w0BAQUFAAOCAQEA\nVlcfyq6GwyE8i0QuFPCeVOwJaneSvcwx316DApjy9/tt2YD2HomLbtpXtji5QXor\nON6oln4tWBIB3Klbr3szq5oR3Rc1D02SaBTalxSndp4M6UkW9hRFu5jn98pDB4fq\n5l8wMMU0Xdmqx1VYvysVAjVFVC/W4NNvlmg+2mEgSVZP5K6Tc9qDh3eMQInoYw6h\nt1YA6RsUJHp5vGQyhP1x34YpLAaly8icbns/8PqOf7Osn9ztmg8bOMJCeb32eQLj\n6mKCwjpegytE0oifXfF8k75A9105cBnNiMZOe1tXiqYc/exCgWvbggurzDOcRkZu\n/YSusaiDXHKU2O3Akc3htA==\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2013-12-19"
  s.description = "Pg is the Ruby interface to the {PostgreSQL RDBMS}[http://www.postgresql.org/].\n\nIt works with {PostgreSQL 8.4 and later}[http://www.postgresql.org/support/versioning/].\n\nA small example usage:\n\n  #!/usr/bin/env ruby\n\n  require 'pg'\n\n  # Output a table of current connections to the DB\n  conn = PG.connect( dbname: 'sales' )\n  conn.exec( \"SELECT * FROM pg_stat_activity\" ) do |result|\n    puts \"     PID | User             | Query\"\n  result.each do |row|\n      puts \" %7d | %-16s | %s \" %\n        row.values_at('procpid', 'usename', 'current_query')\n    end\n  end".freeze
  s.email = ["ged@FaerieMUD.org".freeze, "lars@greiz-reinsdorf.de".freeze]
  s.extensions = ["ext/extconf.rb".freeze]
  s.extra_rdoc_files = ["Contributors.rdoc".freeze, "History.rdoc".freeze, "Manifest.txt".freeze, "README-OS_X.rdoc".freeze, "README-Windows.rdoc".freeze, "README.ja.rdoc".freeze, "README.rdoc".freeze, "ext/errorcodes.txt".freeze, "POSTGRES".freeze, "LICENSE".freeze, "ext/gvl_wrappers.c".freeze, "ext/pg.c".freeze, "ext/pg_connection.c".freeze, "ext/pg_errors.c".freeze, "ext/pg_result.c".freeze]
  s.files = ["Contributors.rdoc".freeze, "History.rdoc".freeze, "LICENSE".freeze, "Manifest.txt".freeze, "POSTGRES".freeze, "README-OS_X.rdoc".freeze, "README-Windows.rdoc".freeze, "README.ja.rdoc".freeze, "README.rdoc".freeze, "ext/errorcodes.txt".freeze, "ext/extconf.rb".freeze, "ext/gvl_wrappers.c".freeze, "ext/pg.c".freeze, "ext/pg_connection.c".freeze, "ext/pg_errors.c".freeze, "ext/pg_result.c".freeze]
  s.homepage = "https://bitbucket.org/ged/ruby-pg".freeze
  s.licenses = ["BSD".freeze, "Ruby".freeze, "GPL".freeze]
  s.rdoc_options = ["-f".freeze, "fivefish".freeze, "-t".freeze, "pg: The Ruby Interface to PostgreSQL".freeze, "-m".freeze, "README.rdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7".freeze)
  s.rubyforge_project = "pg".freeze
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Pg is the Ruby interface to the {PostgreSQL RDBMS}[http://www.postgresql.org/]".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4.0"])
      s.add_development_dependency(%q<hoe-highline>.freeze, ["~> 0.1.0"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 4.0"])
      s.add_development_dependency(%q<rake-compiler>.freeze, ["~> 0.9"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.5.1"])
      s.add_development_dependency(%q<hoe-deveiate>.freeze, ["~> 0.2"])
      s.add_development_dependency(%q<hoe-bundler>.freeze, ["~> 1.0"])
    else
      s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4.0"])
      s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.1.0"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 4.0"])
      s.add_dependency(%q<rake-compiler>.freeze, ["~> 0.9"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.5.1"])
      s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.2"])
      s.add_dependency(%q<hoe-bundler>.freeze, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4.0"])
    s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.1.0"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 4.0"])
    s.add_dependency(%q<rake-compiler>.freeze, ["~> 0.9"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.5.1"])
    s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.2"])
    s.add_dependency(%q<hoe-bundler>.freeze, ["~> 1.0"])
  end
end

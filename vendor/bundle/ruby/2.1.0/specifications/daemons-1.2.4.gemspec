# -*- encoding: utf-8 -*-
# stub: daemons 1.2.4 ruby lib

Gem::Specification.new do |s|
  s.name = "daemons"
  s.version = "1.2.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Thomas Uehlinger"]
  s.date = "2016-08-01"
  s.description = "    Daemons provides an easy way to wrap existing ruby scripts (for example a\n    self-written server)  to be run as a daemon and to be controlled by simple\n    start/stop/restart commands.\n\n    You can also call blocks as daemons and control them from the parent or just\n    daemonize the current process.\n\n    Besides this basic functionality, daemons offers many advanced features like\n    exception backtracing and logging (in case your ruby script crashes) and\n    monitoring and automatic restarting of your processes if they crash.\n"
  s.email = "thomas.uehinger@gmail.com"
  s.homepage = "https://github.com/thuehlinger/daemons"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "A toolkit to create and control daemons in different ways"

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, ["~> 0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.1"])
      s.add_development_dependency(%q<simplecov>, ["~> 0"])
      s.add_development_dependency(%q<pry-byebug>, ["~> 0"])
    else
      s.add_dependency(%q<rake>, ["~> 0"])
      s.add_dependency(%q<rspec>, ["~> 3.1"])
      s.add_dependency(%q<simplecov>, ["~> 0"])
      s.add_dependency(%q<pry-byebug>, ["~> 0"])
    end
  else
    s.add_dependency(%q<rake>, ["~> 0"])
    s.add_dependency(%q<rspec>, ["~> 3.1"])
    s.add_dependency(%q<simplecov>, ["~> 0"])
    s.add_dependency(%q<pry-byebug>, ["~> 0"])
  end
end

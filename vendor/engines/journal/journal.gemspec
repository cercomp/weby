$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "journal/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "journal"
  s.version     = Journal::VERSION
  s.authors     = ["Cercomp: Equipe Web"]
  s.email       = ["web@cercomp.ufg.br"]
  s.homepage    = "http://weby.cercomp.ufg.br"
  s.summary     = "News extension"
  s.description = "Add news funcionality to the site"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "> 4.0"
end

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sticker/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sticker"
  s.version     = Sticker::VERSION
  s.authors     = ["Cercomp: Equipe Web"]
  s.email       = ["web@cercomp.ufg.br"]
  s.homepage    = "http://weby.cercomp.ufg.br"
  s.summary     = "Stick banners in your site."
  s.description = "An simple banner system for the Weby CMS."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "> 4.0"
end

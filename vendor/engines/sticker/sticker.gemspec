$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sticker/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sticker"
  s.version     = Sticker::VERSION
  s.authors     = ["Cercomp: Equipe Web"]
  s.email       = ["web@cercomp.ufg.br"]
  s.homepage    = "http://www.cercomp.ufg.br"
  s.summary     = "Stick banners in your site."
  s.description = "An simple banner system for the Weby CMS."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.17"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
# coding: UTF-8
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "acadufg/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "acadufg"
  s.version     = Acadufg::VERSION
  s.authors     = ["Cercomp - equipe web"]
  s.email       = ["web@cercomp.ufg.br"]
  s.homepage    = "http://weby.cercomp.ufg.br"
  s.summary     = "Listagem de professores integrada"
  s.description = "Cliente do webservice de listagem dos professores - UFG"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "weby", "~> 0.3"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end

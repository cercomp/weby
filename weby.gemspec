# Encoding: UTF-8

Gem::Specification.new do |gem|
  gem.authors       = ["Equipe Web"]
  gem.email         = ["web@cercomp.ufg.br"]
  gem.description   = %q{Write a gem description}
  gem.summary       = %q{Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split("\n")
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "weby"
  gem.require_paths = ["lib"]

  gem.version       = %q{0.3}
end

# Loads the configurations for secure connection with the UFG API
# Creates a Hash with the configurations

CONNECTION = YAML.load(ERB.new(File.read(Acadufg::Engine.root.join("config", "security.yml"))).result)[Rails.env]



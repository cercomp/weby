# Loads the layouts divisions from layout.yml
# Creates a Hash with the positions names

LAYOUTS = YAML.load(ERB.new(File.read(Rails.root.join("config","layout.yml"))).result)[Rails.env]


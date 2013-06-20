module Weby::Themes

  @@themes = {}
  Dir.glob(File.join("lib", "weby", "themes", "*")) do |file|
    next unless File.directory?(file)
    theme = file.match(/(\w+)$/)[1]
    layout_yaml = "lib/weby/themes/#{theme}/layout.yml"
    @@themes[theme] = YAML.load_file(Rails.root.join(layout_yaml)) if File.exists? layout_yaml
  end
  #@@themes.sort!

  def self.all
    @@themes.keys.sort
  end

  def self.layout theme
    @@themes[theme]
  end

end

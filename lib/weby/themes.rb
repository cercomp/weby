module Weby::Themes
  @@themes = {}
  Dir.glob(File.join('lib', 'weby', 'themes', '*')) do |file|
    next unless File.directory?(file)
    theme = file.match(/(\w+)$/)[1]
    @@themes[theme] = Weby::Theme.new(theme)
  end
  # @@themes.sort!

  def self.all
    @@themes.values #.keys.sort
  end

  def self.theme(name)
    @@themes[name]
  end
end

class Weby::Extension
  attr_accessor :name, :author, :version, :disabled, :settings, :menu_position

  def initialize(name, options = {})
    @name = name
    @author = options[:author]
    @version = eval(name.to_s.titleize)::VERSION
    @disabled = false
    @settings = options[:settings] || []
    @menu_position = options[:menu_position] || :last
  end

  # route matches ==========================
  def matches?(request)
    site = Weby::Subdomain.find_site
    site.has_extension(@name) if site
  end
end

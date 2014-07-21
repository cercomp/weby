class Weby::Extension
  attr_accessor :name, :author, :version, :disabled, :settings

  def initialize(name, options = {})
    self.name = name
    self.author = options[:author]
    self.version = eval(name.to_s.titleize)::VERSION
    self.disabled = false
    self.settings = options[:settings] || []
  end
end

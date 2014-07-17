class Weby::Extension
  attr_accessor :name, :author, :version, :disabled, :settings

  def initialize(name, author, *args)
    self.name = name
    self.author = author
    self.version = eval(name.to_s.titleize)::VERSION
    self.disabled = false
    self.settings = args[0]
  end
end

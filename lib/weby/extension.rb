class Weby::Extension
  attr_accessor :name, :author, :version, :disabled

  def initialize(name, author)
    self.name = name
    self.author = author
    self.version = eval(name.to_s.titleize)::VERSION
    self.disabled = false
  end
end

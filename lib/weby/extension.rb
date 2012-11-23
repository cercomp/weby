class Weby::Extension
  attr_accessor :name, :author

  def initialize(name, author)
    self.name = name
    self.author = author
  end
end

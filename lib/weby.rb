module Weby
  autoload :Extension, 'weby/extension'

  @@extensions = {}
  def self.extensions
    @@extensions
  end

  def self.register_extension(extension)
    @@extensions[extension.name] = extension
  end
end

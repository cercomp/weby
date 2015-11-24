module Weby
  autoload :Extension, 'weby/extension'
  class << self
    @@extensions = {}

    def register_extension(extension)
      @@extensions[extension.name] = extension
    end

    def extensions
      @@extensions
    end
  end
end

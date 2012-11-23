module Weby
  autoload :Extension, 'weby/extension'

  @@extensions = []
  def self.extensions
    @@extensions
  end
end

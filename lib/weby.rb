module Weby
  autoload :Extension, 'weby/extension'
  class << self
    @@extensions = {}
    @@institutions = {}

    begin
      file = 'lib/weby/institutions/institutions.yml'
      @@institutions = YAML.load_file(file) if File.exist? file
    end

    def institutions
      @@institutions
    end

    def register_extension(extension)
      @@extensions[extension.name] = extension
    end

    def extensions
      @@extensions
    end
  end
end

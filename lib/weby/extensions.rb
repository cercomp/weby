module Weby
  class Extensions
    def self.matches?(request)
      extension = self.find_extension_in_path(request.fullpath)
      return (!extension.nil? && Site.find_by_id(@site_id).has_extension(extension))
    end

    def self.find_extension_in_path(path)
      path.match /\/([\w\d]*)\/?/
      return $1
    end    
  end
end

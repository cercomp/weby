module Weby
  class Extensions
    class << self

      # route matches ==========================
      def matches?(request)
        extension = self.find_extension_in_path(request.fullpath)
        @site_id = request.subdomain.gsub(/www\./, '')
        return (!extension.nil? && Site.find_by_name(@site_id).has_extension(extension))
      end

      def find_extension_in_path(path)
        path.match /\/([\w\d]*)\/?/
        return $1
      end    
    end

  end
end

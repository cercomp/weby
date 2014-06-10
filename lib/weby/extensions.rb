module Weby
  class Extensions
    class << self
      # route matches ==========================
      def matches?(request)
        extension = find_extension_in_path(request.fullpath)
        site = Weby::Subdomain.find_site
        extension && site.has_extension(extension)
      end

      def find_extension_in_path(path)
        path.match(/\/([\w\d]*)\/?/)
        Regexp.last_match[1]
      end
    end
  end
end

module Weby
  class Subdomain
    include ActionDispatch::Http::URL

    def self.matches?(request)
      settings = (Weby::Cache.request[:settings] ||= Hash[Setting.all.map{|st| [st.name.to_sym,st.value] }])
      root_site  = settings[:root_site]
      index_id   = settings[:sites_index]
      tld_length = settings[:tld_length]
      @site_id = nil

      @@tld_length = (tld_length ? tld_length : '1').to_i

      if request.subdomain.present? && request.subdomain != "www"
        if index_id
          return false if request.subdomain == index_id
        end
        @site_id = request.subdomain.gsub(/www\./, '') and return true
      else
        @site_id = root_site and return true if root_site
      end
    end

    def self.site_id
      @site_id
    end
  end
end
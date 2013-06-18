module Weby
  class Subdomain
    include ActionDispatch::Http::URL

    def self.matches?(request)
      settings = (Weby::Cache.request[:settings] ||= Hash[Setting.all.map{|st| [st.name.to_sym,st.value] }])
      root_site  = settings[:root_site]
      index_id   = settings[:sites_index]
      tld_length = settings[:tld_length]
      @site_domain = nil

      @@tld_length = (tld_length ? tld_length : '1').to_i

      if request.subdomain.present? && request.subdomain != "www"
        if index_id
          return false if request.subdomain == index_id
        end
        @site_domain = request.subdomain.gsub(/www\./, '') and return true
      else
        @site_domain = root_site and return true if root_site
      end
    end

    def self.site_id
      @site_domain
    end

    def self.find_site(domain=nil)
      domain = @site_domain unless domain
      sites = domain.split('.')
      site = Site.where(parent_id: nil).find_by_name(sites[-1])
      if(sites.length == 2)
        site = site.subsites.find_by_name(sites[-2]) if site
      end
      site if [1,2].include? sites.length
    end
  end
end

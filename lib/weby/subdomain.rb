module Weby
  class Subdomain
    include ActionDispatch::Http::URL

    def self.matches?(request)
      #TODO deixar o acesso a Settings mais eficiente, aqui e no sistema inteiro
      # menos acessos ao banco
      settings = Setting.all
      root_site = settings.select{ |s| s.name == 'root_site'}[0]
      index_id   = settings.select{ |s| s.name == 'sites_index'}[0]
      tld_length = settings.select{ |s| s.name == 'tld_length'}[0]
      @site_id = nil

      @@tld_length = (tld_length ? tld_length.value : '1').to_i

      if request.subdomain.present? && request.subdomain != "www"
        if index_id
          return false if request.subdomain == index_id.value
        end
        @site_id = request.subdomain.gsub(/www\./, '') and return true
      else
        @site_id = root_site.value and return true if root_site
      end
    end

    def self.site_id
      @site_id
    end
  end
end
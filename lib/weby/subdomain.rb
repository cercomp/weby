module Weby
  class Subdomain
    include ActionDispatch::Http::URL

    def self.extract_subdomain(request, settings)
      if settings.domain.present? && request.host.end_with?(settings.domain)
        sub = request.host.sub(/\.?#{Regexp.escape(settings.domain)}(:\d+)?$/, '')
        sub.gsub(/^www\./, '')
      else
        tld_len = settings.tld_length.present? ? settings.tld_length.to_i : 1
        request.subdomain(tld_len).gsub(/^www\./, '')
      end
    end

    def self.matches?(request)
      settings = Weby::Settings::Weby
      @site_domain = nil

      # Suporte a multidomínio: aceita qualquer domínio externo cadastrado
      if ApplicationController.is_external_site?(request)
        @site_domain = request.host.gsub(/^www\./, '')
        return true
      end

      subdomain = extract_subdomain(request, settings)

      if subdomain.present? && subdomain != 'www'
        if settings.sites_index.present?
          return false if subdomain == settings.sites_index
        end
        @site_domain = subdomain and return true
      else
        @site_domain = settings.root_site and return true if settings.root_site.present?
      end
    end

    def self.site_id
      @site_domain
    end

    def self.find_site(domain = nil)
      domain = @site_domain unless domain
      return nil if domain.blank?
      domain = domain.gsub(/^www\./, '')
      sites = domain.split('.')
      
      if sites.length == 2
        site = Site.where(parent_id: nil).find_by_name(sites[-1])
        site = site.subsites.active.find_by_name(sites[-2]) if site
      elsif sites.length == 1
        site = Site.active.where(parent_id: nil).find_by_name(sites[-1])
      end
      site if [1, 2].include? sites.length
    end

    def self.find_external_site(domain = nil)
      domain = @site_domain unless domain
      return nil if domain.blank?
      domain = domain.gsub(/^www\./, '')
      sites = domain.split('.')
      
      site = Site.active.where(parent_id: nil).find_by_name_and_domain(sites[0], sites[1..-1].join('.'))
    end
  end
end

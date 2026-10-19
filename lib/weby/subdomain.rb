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

      cache_key = "weby:subdomain:site_id:#{domain}"
      site_id = Rails.cache.read(cache_key)
      if site_id.nil?
        sites = domain.split('.')
        resolved = nil
        if sites.length == 2
          resolved = Site.where(parent_id: nil).find_by_name(sites[-1])
          resolved = resolved.subsites.active.find_by_name(sites[-2]) if resolved
        elsif sites.length == 1
          resolved = Site.active.where(parent_id: nil).find_by_name(sites[-1])
        end
        if resolved
          site_id = resolved.id
          Rails.cache.write(cache_key, site_id, expires_in: 30.minutes)
        end
      end

      Site.find_by(id: site_id) if site_id
    end

    def self.find_external_site(domain = nil)
      domain = @site_domain unless domain
      return nil if domain.blank?
      domain = domain.gsub(/^www\./, '')

      cache_key = "weby:subdomain:ext_site_id:#{domain}"
      site_id = Rails.cache.read(cache_key)
      if site_id.nil?
        sites = domain.split('.')
        resolved = Site.active.where(parent_id: nil).find_by_name_and_domain(sites[0], sites[1..-1].join('.'))
        if resolved
          site_id = resolved.id
          Rails.cache.write(cache_key, site_id, expires_in: 30.minutes)
        end
      end

      Site.find_by(id: site_id) if site_id
    end
  end
end

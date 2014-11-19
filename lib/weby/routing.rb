require 'action_dispatch/routing/route_set'

module ActionDispatch
  module Routing
    class RouteSet
      def with_subdomain(site, _options)
        domain = Weby::Settings::Weby.domain || Weby::Cache.request[:domain]
        if not site
          subdomain = Weby::Settings::Weby.sites_index
        else
          if site.is_a? Site
            if site.domain.present?
              domain = site.domain
            end
            if Weby::Subdomain.site_id.present? # not global scope
              prefix = Weby::Cache.request[:subdomain].match(/www\./).to_s
            else
              # TODO colocar ou não o "www."?
              prefix = 'www.'
            end
            subdomain = site.main_site ? "#{site.name}.#{site.main_site.name}" : "#{prefix}#{site.name}"
            # TODO colocar ou não o "www."?
            subdomain = 'www' if subdomain.gsub(/www\./, '') == Weby::Settings::Weby.root_site
          else
            subdomain = site
          end
        end
        subdomain += '.' if subdomain.present?
        "#{subdomain}#{domain}"
      end

      def url_for_with_subdomains(options)
        if options.kind_of?(Hash)
          if options.key?(:subdomain)
            options[:host] = with_subdomain(options.delete(:subdomain), options)
          else
            # puts options
            fail ActionController::RoutingError.new 'Subdomain missing' if !options[:only_path] && %w(site site_page).include?(options[:use_route])
          end
        end
        options[:protocol] ||= Weby::Settings::Weby.login_protocol if Weby::Cache.request[:current_user]
        url_for_without_subdomains(options)
      end
      alias_method_chain :url_for, :subdomains
    end
  end
end

require 'action_dispatch/routing/route_set'

module ActionDispatch
  module Routing
    class RouteSet
      def with_subdomain(site, options)
        if not site
          subdomain = Weby::Settings.sites_index
        else
          if site.class == Site
            #TODO colocar ou não o "www."?
            prefix = options[:use_route] == 'site_page' ? Weby::Cache.request[:subdomain].match(/www\./).to_s : "www."
            subdomain = site.main_site ? "#{site.name}.#{site.main_site.name}" : "#{prefix}#{site.name}"
          else
            subdomain = site
          end
        end
        subdomain += "." if subdomain.present?
        [subdomain ,Weby::Cache.request[:domain]].join
      end

      def url_for_with_subdomains(options)
#        if SubdomainFu.needs_rewrite?(options[:subdomain], (options[:host] || (@request && @request.host_with_port))) || options[:only_path] == false
#          options[:only_path] = false if SubdomainFu.override_only_path?
#          options[:host] = SubdomainFu.rewrite_host_for_subdomains(options.delete(:subdomain), options[:host] || (@request && @request.host_with_port))
#        else
#          options.delete(:subdomain)
#        end
#        url_for_without_subdomains(options)
        if options.kind_of?(Hash)
          if options.has_key?(:subdomain)
            options[:host] = with_subdomain(options.delete(:subdomain), options)
          else
            #puts options
            raise ActionController::RoutingError.new "Subdomain missing" if !options[:only_path] && ['site','site_page'].include?(options[:use_route])
          end
        end
        url_for_without_subdomains(options)
      end
      alias_method_chain :url_for, :subdomains
    end
  end
end
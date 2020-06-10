require 'action_dispatch/routing/route_set'

module SubdomainRoute
  def with_subdomain(site, _options)
    port = Weby::Cache.request[:port]
    domain = Weby::Settings::Weby.domain || [Weby::Cache.request[:domain], port.to_i == 80 ? nil : port].compact.join(':')
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
          prefix = 'www.' if site.name == Weby::Settings::Weby.root_site
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

  def url_for(options, route_name = nil, url_strategy = ActionDispatch::Routing::RouteSet::UNKNOWN)
    if options.kind_of?(Hash)
      if options.key?(:subdomain)
        options[:host] = with_subdomain(options.delete(:subdomain), options)
      else
        # puts options
        fail ActionController::RoutingError.new 'Subdomain missing' if !options[:only_path] && %w(site site_page).include?(options[:use_route])
      end
    end
    options[:protocol] ||= Weby::Settings::Weby.login_protocol if Weby::Cache.request[:current_user]
    super(options, route_name, url_strategy)
  end
end

ActionDispatch::Routing::RouteSet.prepend(SubdomainRoute)

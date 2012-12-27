module UrlHelper
  def with_subdomain(site)
    if not site
      subdomain = current_settings[:sites_index] || ""
    else
      if site.class == Site
        #TODO colocar ou não o "www."?
        subdomain = site.main_site ? "#{site.name}.#{site.main_site.name}" : "www.#{site.name}"
      else
        subdomain = site
      end
    end
    subdomain += "." unless subdomain.empty?
    [subdomain ,request.domain].join
  end

  def url_for(options = nil)
    if options.kind_of?(Hash) 
      if options.has_key?(:subdomain)
        options[:host] = with_subdomain(options.delete(:subdomain))
      else
        #puts options
        raise ActionController::RoutingError.new "Subdomain missing" if !options[:only_path] && ['site','site_page'].include?(options[:use_route])
      end
    end
    super
  end
end

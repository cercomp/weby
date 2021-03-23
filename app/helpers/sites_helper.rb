# coding: utf-8
module SitesHelper

  def include_facebook_script
    if @fb_included.blank?
      @fb_included = true
      "<div id=\"fb-root\"></div>"+
      "<script async defer crossorigin=\"anonymous\" src=\"https://connect.facebook.net/#{current_locale == 'pt-BR' ? 'pt_BR' : 'en_US'}/sdk.js#xfbml=1&version=v10.0&appId=260966418946169&autoLogAppEvents=1\" nonce=\"rGWiLV7l\"></script>"
    else
      ""
    end.html_safe
  end


  def render_social_share type, obj
    html = '<div class="social-buttons">'
    if current_site.send("#{type}_social_share_networks".to_sym).to_a.include?('twitter')
      html += '<a href="https://twitter.com/share" data-size="large" class="twitter-share-button">Tweet</a>'
      html += "<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>"
    end
    if current_site.send("#{type}_social_share_networks".to_sym).to_a.include?('facebook')
      _href = request.original_url.gsub(/\?.*/, '')
      html += include_facebook_script
      html += "<div class=\"fb-like\" data-href=\"\" data-width=\"\" data-layout=\"button_count\" data-action=\"like\" data-size=\"large\" data-show-faces=\"true\" data-share=\"true\"></div>"
    end
    if current_site.send("#{type}_social_share_networks".to_sym).to_a.include?('whatsapp')
      domain = is_on_mobile? ? 'whatsapp://' : 'https://web.whatsapp.com/'
      _url = %(#{domain}send?text=#{obj&.title || obj&.name}%0A#{Rack::Utils.escape(request.original_url)})
      html += content_tag(:div, link_to('WhatsApp', _url, target: :_blank), class: 'wtsp-share')
    end
    html += '</div>'
    html.html_safe
  end

  def site_status_options
    [[t('active'), 'active'], [t('inactive'), 'inactive']]
  end

  def main_sites_list curr_site
    Site.where(parent_id: nil).order('name') - [curr_site]
  end

  def main_sites_options site
    main_sites_list(site).collect do |s|
      ["#{s.name} (#{s.title})#{ " [#{t('inactive')}]" if !s.active? }" ,s.id, {data: {name: s.name}}]
    end
  end

  def default_domain
    port = Weby::Cache.request[:port]
    Weby::Settings::Weby.domain || [Weby::Cache.request[:domain], port.to_i == 80 ? nil : port].compact.join(':')
  end

  def render_site_url site
    parts = site.url_parts
    placeholder = Site.human_attribute_name(:name)
    content_tag :div, class: 'form-group' do
      concat content_tag :label, 'URL'
      concat( content_tag(:div, class: 'url-preview') do
        concat content_tag(:span, parts[:site_name].present? ? parts[:site_name] : "[#{placeholder}].", class: 'site-domain', data: {placeholder: placeholder})
        concat content_tag(:span, parts[:parent_name], class: 'parent-domain')
        concat content_tag(:span, parts[:site_domain], class: 'domain', data: {default: parts[:default_domain]})
      end)
    end
  end

  def contrast_stylesheet_link url
    is_contrast_mode = current_user && current_user.preferences['contrast'].to_i == 1
    href = is_contrast_mode ? url : ''
    stylesheet_link_tag(href, class: "contrast-css #{'active' if is_contrast_mode}", data: {src: url})
  end
end
module PagesHelper
  def locale_with_name(locale)
    raw %{
      #{image_tag("flags/24/#{locale.flag}", :title=>t(locale.name))} 
      #{t(locale.name)}
    } if locale
  end

  def title_with_flags(page)
    %{
      #{available_flags(page)}
      #{content_tag(:p, link_to(page.title, site_page_path(@site, page)))}
    }.html_safe
  end

  def available_flags(page)
    if @site.locales.many?
      page.locales.map do |locale|
        flag_link(locale, site_page_path(@site, page, page_locale: locale.name), '16')
      end.join(' ')
    end
  end
end

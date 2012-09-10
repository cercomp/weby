module PagesHelper
  # Retorna um link externo quando existente ou um link interno da página.
  # Recebe uma página e o site.
  def link_on_title(site, page)
    if page.url.nil? or page.url.empty?
      site_page_url(page, subdomain: site)
    else
      page.url
    end
  end

  def locale_with_name(locale)
    raw %{
      #{flag(locale)}
      #{t(locale.name)}
    } if locale
  end

  def title_with_flags(page)
    %{
      #{available_flags(page)}
      #{content_tag(:p, link_to(page.title, site_admin_page_path(page)))}
    }.html_safe
  end

  def available_flags(page, size = '16')
    if @site.locales.many?
      "#{main_flag(page, size)}#{other_flags(page, size)}"
    end
  end

  def main_flag(page, size = '16')
    flag(page.which_locale, size, style: 'padding-right: 10px')
  end

  def other_flags(page, size = '16')
    page.other_locales.map do |locale|
      link_to(flag(locale, size), send((is_in_admin_context? ? :site_admin_page_path : :site_page_path) ,page, page_locale: locale.name) )
    end.join(' ')
  end
end

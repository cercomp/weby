module PagesHelper
  # Input: receives(Site, Page)
  # Output: Returns an external link when it exists or the link to a Page
  def link_on_title(site, page)
    if page.url.blank?
      main_app.site_page_url(page, subdomain: site)
    else
      page.url
    end
  end

  def locale_with_name(locale, size = '24')
    raw %(
      #{flag(locale, size)}
      #{t(locale.name)}
    ) if locale
  end

  def title_with_flags(page)
    %(
      #{available_flags(page)}
      #{content_tag(:p, link_to(page.title, site_admin_page_path(page)))}
    ).html_safe
  end

  def available_flags(page, size = '16')
    "#{main_flag(page, size)}#{other_flags(page, size)}" if @site.locales.many?
  end

  def main_flag(page, size = '16')
    flag(page.which_locale, size, style: 'padding-right: 10px')
  end

  def other_flags(page, size = '16')
    page.other_locales.map do |locale|
      link_to(flag(locale, size), send((is_in_admin_context? ? :site_admin_page_path : :site_page_path) , page, page_locale: locale.name))
    end.join(' ')
  end

  def categories_links(categories)
    ''.tap do |link|
      categories.each do |category|
        link << link_to(category, site_pages_path(tags: category)) + ",\n"
      end
      link.chomp!
      link.chop!
    end
  end
end

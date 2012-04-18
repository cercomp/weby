module PagesHelper
  def locale_with_name(locale)
    raw %{
      #{flag(locale)}
      #{t(locale.name)}
    } if locale
  end

  def title_with_flags(page)
    %{
      #{available_flags(page)}
      #{content_tag(:p, link_to(page.title, site_page_path(@site, page)))}
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
      link_to(flag(locale, size), site_page_path(@site, page, page_locale: locale.name))
    end.join(' ')
  end
end

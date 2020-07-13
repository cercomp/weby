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

  def locale_with_name(locale, size = :regular)
    raw %(
      #{flag(locale, size: size)}
      #{t(locale.name)}
    ) if locale
  end

  def title_with_flags(post)
    %(
      #{available_flags(post)}
      #{content_tag(:p, link_to(post.title, generate_url(post)))}
    ).html_safe
  end

  def available_flags(post, size = :small)
    "#{main_flag(post, size)}#{other_flags(post, size)}" if @site.locales.many?
  end

  def main_flag(post, size = :small)
    flag(post.which_locale, size: size, style: 'margin-right: 10px')
  end

  def other_flags(post, size = :small)
    post.other_locales.map do |locale|
      link_to(flag(locale, size: size), generate_url(post, show_locale: locale.name))
    end.join(' ')
  end

  def generate_url post, options = {}
    case post
    when Page
      is_in_admin_context? ? site_admin_page_path(post, options) : site_page_path(post, options)
    when Journal::News
      is_in_admin_context? ? admin_news_path(post, options) : news_path(post, options)
    when Calendar::Event
      is_in_admin_context? ? admin_event_path(post, options) : event_path(post, options)
    end
  end

  def categories_links(categories)
    # ''.tap do |link|
    #   categories.each do |category|
    #     link << link_to(category, site_pages_path(tags: category)) + ",\n"
    #   end
    #   link.chomp!
    #   link.chop!
    # end

    categories.map do |category|
      content_tag(:span, category.name, class: 'label label-info')
    end.join(' ').html_safe
  end
end

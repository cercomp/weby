module DateHelper
  def print_date_end(date, format = :short)
    return  t('infinite') if date.nil?
    l(date, format: format)
  end

  # Receives an object (Page, Banner) and verifies if the publication's date has expired
  # Returns toggle_field if not expired otherwise returns "Expired"
  def publication_status(obj, _options = {})
    case obj
    when Page
      publication_status_page(obj, _options)
    when Journal::News
      # DEPRECATED
      #publication_status_news(obj, _options)
    end
  end

  def publication_status_page(page, options = {})
    ''.tap do |html|
      html << toggle_field(page, 'publish', 'toggle', options)
    end.html_safe
  end
  private :publication_status_page

  # DEPRECATED - News no longer has the 'publish' field
  def publication_status_news(news, options = {})
    ''.tap do |html|
      html << toggle_field(news, 'publish', 'toggle', options)
      if news.date_begin_at && Time.current < news.date_begin_at && news.published?
        html << content_tag(:span, fa_icon(:'clock-o'), class: 'publish-warning text-warning', title: t('scheduled', date: l(news.date_begin_at, format: :medium)))
      end
    end.html_safe
  end
  private :publication_status_news

  def front_status(news_site, options = {})
    ''.tap do |html|
      html << toggle_field(news_site, 'front', 'toggle', options)
      if news_site.news.date_end_at && news_site.news.date_end_at <= Time.current #&& news_site.front
        html << content_tag(:span, fa_icon(:'exclamation-circle'), class: 'publish-warning text-danger', title: t('expired_at', date: l(news_site.news.date_end_at, format: :medium)))
      end
    end.html_safe
  end

  def map_months_from_date(end_date)
    end_date ||= Time.current
    months, curr_date = [], Time.current
    while curr_date.beginning_of_month >= end_date.beginning_of_month
      months << [l(curr_date.to_date, format: :monthly), curr_date.strftime('%m/%Y')] # TODO use a block for cutsom format
      curr_date -= 1.month
    end
    [Time.current.year.downto(end_date.year).to_a, months]
  end
end

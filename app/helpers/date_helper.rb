module DateHelper
  def print_date_end(date, format = :short)
    return  t("infinite") if date.nil?
    return l(date, format: format)
  end

  # Receives an object (Page, Banner) and verifies if the publication's date has expired 
  # Returns toggle_field if not expired otherwise returns "Expired"
  def publication_status(obj, options={})
    case obj
    when Page
      publication_status_page(obj, options={})
    when Banner
      publication_status_banner(obj, options={})
    end
  end

  def publication_status_page(page, options={})
    "".tap do |html|
      html << toggle_field(page, "publish", 'toggle', options)
      html << "<span class=\"label label-warning publish-warning\" title=\"#{t("scheduled", date: l(page.date_begin_at, format: :short))}\">!</span>" if page.date_begin_at and Time.now < page.date_begin_at and page.publish
    end.html_safe
  end
  private :publication_status_page

  def publication_status_banner(banner, options={})
    "".tap do |html|
      html << toggle_field(banner, "publish", 'toggle', options)
      if banner.publish
        if banner.date_begin_at and Time.now < banner.date_begin_at
          html << "<span class=\"label label-warning publish-warning\" title=\"#{t("scheduled", date: l(banner.date_begin_at, format: :short))}\">!</span>"
        elsif banner.date_end_at and banner.date_end_at <= Time.now
          html << "<span class=\"label label-important publish-warning\" title=\"#{t("expired")}\">!</span>"
        end
      end
    end.html_safe
  end
  private :publication_status_banner

  def front_status(page, options={})
    "".tap do |html|
      html << toggle_field(page, "front", 'toggle', options)
      html << "<span class=\"label label-important publish-warning\" title=\"#{t("expired")}\">!</span>" if page.date_end_at and page.front and page.date_end_at <= Time.now
    end.html_safe
  end

  def map_months_from_date end_date
    end_date ||= Time.now
    months, curr_date = [], Time.now
    while curr_date.beginning_of_month >= end_date.beginning_of_month
      months << [l(curr_date.to_date, format: :monthly), curr_date.strftime('%m/%Y')] #TODO use a block for cutsom format
      curr_date -= 1.month
    end
    [Time.now.year.downto(end_date.year).to_a, months]
  end
end

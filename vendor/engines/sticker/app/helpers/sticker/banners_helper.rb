module Sticker
  module BannersHelper
    def publication_status_banner(banner, options = {})
      ''.tap do |html|
        html << toggle_field(banner, 'publish', 'toggle', options)
        html << availability_bagde_banner(banner)
      end.html_safe
    end

    def availability_bagde_banner(banner)
      html = ''
      if banner.publish
        if banner.date_begin_at && Time.current < banner.date_begin_at
          html << "<span class=\"label label-warning publish-warning\" title=\"#{t('scheduled', date: l(banner.date_begin_at, format: :short))}\">!</span>"
        elsif banner.date_end_at && banner.date_end_at <= Time.current
          html << "<span class=\"label label-important publish-warning\" title=\"#{t('expired')}\">!</span>"
        end
      end
      html.html_safe
    end
  end
end

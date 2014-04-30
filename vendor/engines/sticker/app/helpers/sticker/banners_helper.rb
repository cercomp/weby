module Sticker
  module BannersHelper
    
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

  end
end

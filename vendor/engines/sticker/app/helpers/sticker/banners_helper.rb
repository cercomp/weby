module Sticker
  module BannersHelper
    def publication_status_banner(banner, options = {})
      ''.tap do |html|
        html << toggle_field(banner, 'publish', 'toggle', options.merge({remote: true, class: 'banner-toggle'}))
        html << availability_bagde_banner(banner)
      end.html_safe
    end

    def availability_bagde_banner(banner)
      html = ''
      #if banner.publish
        if banner.date_begin_at && Time.current < banner.date_begin_at
          html << content_tag(:span, fa_icon(:'clock-o'), class: 'publish-warning text-warning', title: t('scheduled', date: l(banner.date_begin_at, format: :medium)))
        elsif banner.date_end_at && banner.date_end_at <= Time.current
          html << content_tag(:span, fa_icon(:'exclamation-circle'), class: 'publish-warning text-danger', title: t('expired_at', date: l(banner.date_end_at, format: :medium)))
        end
      #end
      html.html_safe
    end
  end
end

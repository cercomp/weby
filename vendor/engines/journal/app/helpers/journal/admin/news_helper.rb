module Journal
  module Admin::NewsHelper

    def news_status news
      ''.tap do |html|
        html << content_tag(:span, t("journal.admin.news.form.#{news.status}"), class: "label label-#{STATUS_CLASSES[news.status.to_sym]}")
        if news.date_begin_at && Time.current < news.date_begin_at && news.published?
          html << content_tag(:span, fa_icon(:'clock-o'), class: 'publish-warning text-warning', title: t('scheduled', date: l(news.date_begin_at, format: :medium)))
        end
      end.html_safe
#      '<div class="btn-group">'.tap do |html|
#        html << content_tag(:button,
#                              class: "btn btn-#{STATUS_CLASSES[news.status.to_sym]} btn-xs dropdown-toggle",
#                              type: 'button',
#                              data: {toggle: 'dropdown'}) do
#                                "#{t("journal.admin.news.form.#{news.status}")} <span class=\"caret\"></span>".html_safe
#                              end
#        html << '<ul class="dropdown-menu" role="menu">'
#        Journal::News::STATUS_LIST.each do |name|
#          html << "<li><a href=\"#\">#{name}</a></li>"
#        end
#        html << '</ul>'
#      end.concat('</div>').html_safe
    end

      def publication_status_news(news, remote: false)
        toggle_url = toggle_publish_site_admin_news_path(news)
        checked = news.status == "published"
        content_tag(:a, id: news.id, data: { remote: remote }, rel: "nofollow", "data-method": :patch, href: toggle_url, class: "toggle-publish-link") do
          check_box_tag("publish", "1", checked, class: "toggle weby-toggle", title: "") +
          content_tag(:label, content_tag(:span, '', class: "check-handler"), class: "check-trail")
        end
      end

    private

    STATUS_CLASSES = {published: 'success', draft: 'default', review: 'info'}
  end
end

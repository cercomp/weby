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
        form_tag(toggle_publish_site_admin_news_path(news), method: :patch, remote: true, class: 'toggle-publish-form', data: { type: 'json' }) do
          checkbox_id = "publish_#{news.id}"
          check_box_tag("publish", "1", news.status == "published", class: "toggle weby-toggle", title: "", id: checkbox_id) +
          content_tag(:label, content_tag(:span, '', class: "check-handler"), class: "check-trail", for: checkbox_id)
        end
      end

    private

    STATUS_CLASSES = {published: 'success', draft: 'default', review: 'info'}
  end
end

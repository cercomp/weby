module Journal
  module Admin::NewsHelper

    def news_status news
      ''.tap do |html|
        if news.scheduled?
          html << content_tag(:span, "#{fa_icon(:'clock-o')} #{t('journal.admin.news.status.scheduled', default: 'Agendada')}".html_safe,
                              class: "label label-warning",
                              title: t('scheduled', date: l(news.date_begin_at, format: :medium)))
        elsif news.published?
          html << content_tag(:span, t("journal.admin.news.form.published"), class: "label label-success")
        else
          html << content_tag(:span, t("journal.admin.news.form.#{news.status}"), class: "label label-#{STATUS_CLASSES[news.status.to_sym]}")
        end
      end.html_safe
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

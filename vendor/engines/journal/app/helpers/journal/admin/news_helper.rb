module Journal
  module Admin::NewsHelper

    def news_status news
      content_tag :span, class: "label label-#{STATUS_CLASSES[news.status.to_sym]}" do
        t("journal.admin.news.form.#{news.status}")
      end
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

    private

    STATUS_CLASSES = {published: 'success', draft: 'default', review: 'info'}
  end
end

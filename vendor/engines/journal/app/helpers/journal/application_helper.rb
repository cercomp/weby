module Journal
  module ApplicationHelper

    def news_date_on_list news
      if @extension.show_created_at? || @extension.show_updated_at?
        content_tag :span, class: 'date' do
          if @extension.show_created_at? && !@extension.show_updated_at?
            "#{t("posted_on")}#{localize news.created_at, format: :medium}"
          elsif @extension.show_updated_at? && !@extension.show_created_at?
            "#{t("updated_on")}#{localize news.updated_at, format: :medium}"
          elsif @extension.show_created_at? && @extension.show_updated_at?
            if news.created_at != news.updated_at
              "#{t("updated_on")}#{localize news.updated_at, format: :medium}"
            else
              "#{t("posted_on")}#{localize news.created_at, format: :medium}"
            end
          end
        end
      end
    end
  end
end

module Journal
  class NewsSerializer < ActiveModel::Serializer

    attributes :id, :status, :author, :category_list, :slug,
               :site_id, :source, :front, :position, :view_count,
               :date_begin_at, :date_end_at,
               :created_at, :updated_at, :deleted_at

    attribute :url, key: :redirect_url

    attributes :title, :summary, :text, :locale

    def repository
      object.repository.archive.url
    end

    def category_list
      current_news_site.category_list
    end

    def text
      JSON::dump(object.text)
    end

    def slug
      object.to_param.to_s
    end

    def locale
      I18n.locale
    end

    def author
      object.user.fullname
    end

    def current_news_site
      @curr_ns ||= object.news_sites.find_by(site_id: object.site_id)
    end

    def date_begin_at
      current_news_site.date_begin_at
    end

    def date_end_at
      current_news_site.date_begin_at
    end

    def front
      current_news_site.front
    end

    def position
      current_news_site.front
    end
  end
end

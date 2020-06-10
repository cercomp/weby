module Journal
  class NewsSerializer < ActiveModel::Serializer
    include ::RepositoryHelper

    attributes :id, :status, :author, :category_list, :slug, :image,
               :site_id, :source, :front, :position, :view_count,
               :date_begin_at, :date_end_at,
               :title, :summary, :text, :locale,
               :created_at, :updated_at, :deleted_at

    attribute :url, key: :redirect_url

    def image
      object.image ? object.image.archive.url : nil
    end

    def category_list
      current_news_site.category_list
    end

    def summary
      externalize_links(render_user_content(object.summary), Rails.application.routes.url_helpers.root_url(subdomain:  object.site))
    end

    def text
      externalize_links(render_user_content(object.text), Rails.application.routes.url_helpers.root_url(subdomain:  object.site))
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

    def front
      current_news_site.front
    end

    def position
      current_news_site.position
    end
  end
end

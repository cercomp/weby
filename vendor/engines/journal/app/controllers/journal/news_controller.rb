module Journal
  class NewsController < Journal::ApplicationController
    layout :choose_layout

    helper_method :sort_column
    before_action :check_current_site

    respond_to :html, :js, :json, :rss

    def index
      @news_sites = get_news
      @extension = current_site.extensions.find_by(name: 'journal')

      respond_with(@news_sites) do |format|
        format.rss { render layout: false, content_type: Mime[:xml] } # index.rss.builder
        format.atom { render layout: false, content_type: Mime[:xml] } # index.atom.builder
        format.json { render json: @news_sites.map{|ns| ns.news }.compact, root: 'news', meta: { total: @news_sites.total_count } }
      end
    end

    def show
      @news = current_site.news.find(params[:id])
      @extension = current_site.extensions.find_by(name: 'journal')
      if @extension.show_updated_at == '1' &&
        (@news.i18ns.first.created_at != @news.i18ns.first.updated_at ||
        @extension.show_created_at == '0') &&
        !@news.i18ns.first.updated_at.blank?
          @updated_at = l(@news.i18ns.first.updated_at, format: :short)
      end
      raise ActiveRecord::RecordNotFound if !@news.published? && @news.user != current_user
      if request.path != news_path(@news)
        redirect_to news_path(@news), status: :moved_permanently
        return
      end
    end

    private

    def tags
      unescape_param(params[:tags]).split(',').map { |tag| tag.mb_chars.downcase.to_s }
    end

    def get_news
      get_news_db
    end

    def get_news_es
      # TODO add filter
      result = Journal::NewsSite.perform_search(params[:search])
    end

    def get_news_db
      params[:direction] ||= 'desc'
      params[:page] ||= 1
      # Vai ao banco por linha para recuperar
      # tags e locales
      if params[:tags].present?
        # news_sites = current_site.news_sites.published.tagged_with(tags, any: true)
        # @news = []
        # news_sites.each do |sites|
        #   @news << sites.journal_news_id
        # end
        # result = Journal::News.published.includes(:user, :related_files, :news_sites, :site).where(sites: {status: 'active'}).where('journal_news.id in (?)', @news).
        #      with_search(params[:search], params.fetch(:search_type, 1).to_i).
        #      order(sort_column + ' ' + sort_direction).
        #      page(params[:page]).per(params[:per_page])
        result = current_site.news_sites.published.includes(:categories, news: [:image, :related_files, :site, :i18ns]).
          tagged_with(tags, any: true).
          with_search(params[:search], params.fetch(:search_type, 1).to_i).
          order(sort_column + ' ' + sort_direction).
          page(params[:page]).per(params[:per_page])
      else
        # result = Journal::News.published.includes(:user, :related_files, :news_sites, :site).where(sites: {status: 'active'}).where(site_id: current_site).
        #     with_search(params[:search], params.fetch(:search_type, 1).to_i).
        #     order(sort_column + ' ' + sort_direction).
        #     page(params[:page]).per(params[:per_page])
        result = current_site.news_sites.published.includes(:categories, news: [:image, :related_files, :site, :i18ns]).
          with_search(params[:search], params.fetch(:search_type, 1).to_i).
          order(sort_column + ' ' + sort_direction).
          page(params[:page]).per(params[:per_page])
      end
      result
    end

    def sort_column
      params[:sort] || 'journal_news.id'
    end

    def check_current_site
      render_404 unless current_site
    end
  end
end

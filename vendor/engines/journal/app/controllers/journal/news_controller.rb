module Journal
  class NewsController < Journal::ApplicationController
    layout :choose_layout

    skip_before_action :verify_authenticity_token, only: :show

    helper_method :sort_column
    before_action :check_current_site
    before_action :load_extension, only: [:index, :show]

    respond_to :html, :js, :json, :rss

    def index
      if !request.format.html?
        @news_sites = Journal::News.get_news(current_site, params.merge(sort_column: sort_column, sort_direction: sort_direction))
      end

      respond_with(@news_sites) do |format|
        format.rss { render layout: false, content_type: Mime[:xml] } # index.rss.builder
        format.atom { render layout: false, content_type: Mime[:xml] } # index.atom.builder
        format.json { render json: @news_sites.map{|ns| ns.news }.compact, root: 'news', meta: { total: @news_sites.total_count } }
      end
    end

    def show
      @news = current_site.news.find(params[:id])
      raise ActiveRecord::RecordNotFound if !@news.published? && @news.user != current_user
      if request.path != news_path(@news)
        redirect_to news_path(@news), status: :moved_permanently
        return
      end
    end

    private

    def sort_column
      params[:sort].present? ? params[:sort] : 'journal_news.created_at'
    end

    def check_current_site
      render_404 unless current_site
    end
  end
end

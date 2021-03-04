class Sites::SearchesController < ApplicationController
  layout :choose_layout
  helper Journal::Engine.helpers

  respond_to :html, :js, :json

  def index
    @extension = current_site.extensions.find_by(name: 'journal')
    if !request.format.html?
      @news_sites = Journal::News.get_news(current_site, params.merge(sort_column: news_sort_column, sort_direction: sort_direction))
      @pages = Page.get_pages(current_site, params.merge(sort_column: pages_sort_column, sort_direction: sort_direction))
      @events = Calendar::Event.get_events(current_site, params.merge(sort_column: events_sort_column, sort_direction: sort_direction))
    end

    respond_with(@news_sites) do |format|
      format.json {
        render json: {
          news: @news_sites.map{|ns| ns.news }.compact,
          pages: @pages,
          events: @events
        }, root: 'results', meta: {
          total: {
            news: @news_sites.total_count,
            pages: @pages.total_count,
            events: @events.total_count
          }
        }
      }
    end
  end

  private

  def news_sort_column
    if params[:sort].blank?
      params[:direction] = 'desc'
    end
    params[:sort].presence || 'journal_news.created_at'
  end

  def pages_sort_column
    if params[:sort].blank?
      params[:direction] = 'desc'
    end
    params[:sort].presence || 'pages.created_at'
  end

  def events_sort_column
    if params[:sort].blank?
      params[:direction] = 'desc'
    end
    params[:sort].presence || 'calendar_events.created_at'
  end
end

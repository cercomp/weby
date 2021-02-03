module Calendar
  class EventsController < Calendar::ApplicationController
    layout :choose_layout

    helper_method :sort_column
    before_action :check_current_site

    respond_to :html, :js, :json, :rss, :atom

    def index
      @events = Calendar::Event.get_events_db current_site, params.merge(sort_column: sort_column, sort_direction: sort_direction)

      respond_with(@events) do |format|
        format.rss { render layout: false, content_type: Mime[:xml] } # index.rss.builder
        format.atom { render layout: false, content_type: Mime[:xml] } # index.atom.builder
        format.json { render json: @events, root: 'events', meta: { total: @events.total_count } }
      end
    end

    def calendar
      @events = Calendar::Event.get_events_db current_site, params.merge(sort_column: sort_column, sort_direction: sort_direction, fetch_all: true)
      render json: Calendar::Event.as_fullcalendar_json(@events).to_json
    end

    def show
      @event = current_site.events.find(params[:id])
      if request.path != event_path(@event)
        redirect_to event_path(@event), status: :moved_permanently
        return
      end
    end

    private

    def sort_column
      params[:sort] || 'calendar_events.id'
    end

    def check_current_site
      render_404 unless current_site
    end
  end
end

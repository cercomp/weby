module Calendar
  class EventsController < Calendar::ApplicationController
    layout :choose_layout

    helper_method :sort_column
    before_action :check_current_site
    before_action :find_event, only: :show

    respond_to :html, :js, :json, :rss, :atom

    def index
      desc_default_direction
      @events = get_events

      respond_with(@events) do |format|
        format.rss { render layout: false, content_type: Mime[:xml] }
        format.atom { render layout: false, content_type: Mime[:xml] }
        format.json { render json: @events, root: 'events', meta: { total: @events.total_count } }
      end
    end

    def calendar
      @events = get_events(fetch_all: true)
      render json: Calendar::Event.as_fullcalendar_json(@events).to_json
    end

    def show
      if @event.site_id != current_site.id
        original_site = @event.site
        
        original_event_url = event_url(@event, subdomain: original_site.name)
        
        redirect_to original_event_url, status: :moved_permanently
        return
      end

      if request.path != event_path(@event)
        redirect_to event_path(@event), status: :moved_permanently
        return
      end
    end

    private

    def find_event
      event_sites = current_site.event_sites
      shared_event_ids = event_sites.pluck(:calendar_event_id)

      @event = Calendar::Event.where('calendar_events.id IN (?) OR calendar_events.site_id = ?', 
        shared_event_ids, current_site.id).find_by(id: params[:id])
      
      raise ActiveRecord::RecordNotFound unless @event
    end

    def get_events(additional_params = {})
      event_sites = current_site.event_sites
      shared_event_ids = event_sites.pluck(:calendar_event_id)

      events = Calendar::Event.where('calendar_events.id IN (?) OR calendar_events.site_id = ?', 
        shared_event_ids, current_site.id).
        includes(:user, :site, i18ns: :locale).
        where(sites: { status: 'active' })

      events = events.with_search(params[:search], 1) if params[:search].present?

      events = events.order(sort_column + ' ' + sort_direction)

      unless additional_params[:fetch_all]
        events = events.page(params[:page]).per(params[:per_page])
      end

      events
    end

    def find_event
      event_sites = current_site.event_sites
      shared_event_ids = event_sites.pluck(:calendar_event_id)

      @event = Calendar::Event.where('calendar_events.id IN (?) OR calendar_events.site_id = ?', 
        shared_event_ids, current_site.id).find_by(id: params[:id])
      
      raise ActiveRecord::RecordNotFound unless @event
    end

    def sort_column
      params[:sort] || 'calendar_events.created_at'
    end

    def check_current_site
      render_404 unless current_site
    end
  end
end
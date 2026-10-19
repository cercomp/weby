module Calendar
  class Admin::EventsController < Calendar::ApplicationController
    before_action :require_user
    before_action :check_authorization
    before_action :event_types, only: [:new, :edit, :create, :update, :index]
    before_action :find_event, only: [:show, :edit, :update]

    respond_to :html, :js, :json

    helper_method :sort_column

    def index
      @events = get_events
      respond_with(:admin, @events) do |format|
        if params[:template]
          format.js { render "#{params[:template]}" }
          format.html { render partial: "#{params[:template]}", layout: false }
        end
        format.json { render json: Calendar::Event.as_fullcalendar_json(@events, true).to_json }
      end
    end

    def get_events
      case params[:template]
      when 'tiny_mce'
        params[:per_page] = 7
      end
      params[:direction] ||= 'desc'

      event_sites = current_site.event_sites
      @events_ids = []
      event_sites.each do |sites|
        @events_ids << sites.calendar_event_id
      end

      events = Calendar::Event.where('calendar_events.id IN (?) OR calendar_events.site_id = ?', 
        @events_ids, current_site.id).
        includes(:user, :site, i18ns: :locale, event_sites: :site).
        where(sites: {status: 'active'}).
        with_search(params[:search], 1) 

      if params[:template] == 'list_popup'
        events = events.published if events.respond_to?(:published)
      end

      if sort_column == 'calendar_events_i18ns.name'
        events = events.where(locales: {name: I18n.locale})
      end

      events.order(sort_column + ' ' + sort_direction)
        .page(params[:page]).per(params[:per_page])
    end
    private :get_events

    def unshare
      @event = Calendar::EventSite.where(site_id: current_site.id, calendar_event_id: params[:id])
      log_event = @event.first
      @event.destroy_all
      record_activity('unshared_event', log_event.event) if log_event
      flash[:success] = t('.unshared_event')
      redirect_to admin_events_path
    end

    def destroy_many
      event_ids = params[:ids].split(',')
      
      current_site.event_sites.includes(:event).where(id: event_ids).each do |es|
        if es.event.site_id == current_site.id
          if es.event.trash
            record_activity('moved_event_to_recycle_bin', es.event)
            flash[:success] = t('moved_event_to_recycle_bin')
          end
        else
          if es.destroy
            record_activity('unshared_event', es.event)
            flash[:success] = t('unshared_event')
          end
        end
      end
      redirect_back(fallback_location: admin_events_path)
    end

    def recycle_bin
      params[:sort] ||= 'calendar_events.deleted_at'
      params[:direction] ||= 'desc'
      @events = current_site.events.trashed.includes(:user).
        order("#{params[:sort]} #{sort_direction}").
        page(params[:page]).per(params[:per_page])
    end

    def show
      @event = @event.in(params[:show_locale])
    end

    def new
      @event = current_site.events.new_or_clone(params[:copy_from])
    end

    def create
      @event = current_site.events.new(events_params)
      @event.user = current_user
      @event.save
      record_activity('created_event', @event)
      respond_with(:admin, @event)
    end

    def edit
    end

    def share
      @event = current_site.events.find(params[:id])
      target_site = Site.find(params[:site_id])

      event_site = Calendar::EventSite.find_or_initialize_by(
        calendar_event_id: @event.id,
        site_id: target_site.id
      )
      
      if event_site.new_record? && event_site.save
        record_activity('shared_event', @event)
        flash[:success] = t('.successfully_shared')
      else
        flash[:error] = t('.share_failed')
      end
    
      redirect_back(fallback_location: admin_events_path)
    end
    
    def available_sites_for_share
      @event = current_site.events.find(params[:id])
      @sites = if check_permission(Calendar::Admin::EventsController, [:share])
                Site.where.not(id: [@event.site_id] + @event.event_sites.pluck(:site_id))
              else
                current_user.sites.where.not(id: [@event.site_id] + @event.event_sites.pluck(:site_id))
              end.order(:title)

      respond_to do |format|
        format.html
        format.json { render json: @sites.map { |s| { id: s.id, title: s.title } } }
      end
    end

    def update
      params[:event][:related_file_ids] ||= []
      @event.update(events_params)
      record_activity('updated_event', @event)
      respond_with(:admin, @event)
    end

    def event_types
      @event_types = Calendar::Event::EVENT_TYPES.map { |el| [t("calendar.admin.events.form.#{el}"), el] }
    end
    private :event_types

    def destroy
      @event = current_site.events.unscoped.find(params[:id])
      if @event.trash
        if @event.persisted?
          record_activity('moved_event_to_recycle_bin', @event)
          flash[:success] = t('moved_event_to_recycle_bin')
        else
          record_activity('destroyed_event', @event)
          flash[:success] = t('successfully_deleted')
        end
      else
        flash[:error] = @event.errors.full_messages.join(', ')
      end

      redirect_to @event.persisted? ? admin_events_path : recycle_bin_admin_events_path
    end

    def recover
      @event = current_site.events.trashed.find(params[:id])
      if @event.untrash
        flash[:success] = t('successfully_restored')
      end
      record_activity('restored_event', @event)
      redirect_back(fallback_location: recycle_bin_admin_events_path)
    end

    def destroy_many
      current_site.events.where(id: params[:ids].split(',')).each do |event|
        if event.trash
          record_activity('moved_event_to_recycle_bin', event)
          flash[:success] = t('moved_event_to_recycle_bin')
        end
      end
      redirect_back(fallback_location: admin_events_path)
    end


    def empty_bin
      if current_site.events.trashed.destroy_all
        flash[:success] = t('successfully_deleted')
      end
      redirect_to recycle_bin_admin_events_path
    end

    private

    def find_event
      @event = current_site.events.find(params[:id])
      raise ActiveRecord::RecordNotFound unless @event
    end

    def sort_column
      params[:sort] || 'calendar_events.id'
    end

    def events_params
      params.require(:event).permit(:begin_at, :end_at, :email, :url, :slug,
                                   :kind, :category_list, :image,
                                   { i18ns_attributes: [:id, :locale_id, :name,
                                       :information, :place, :_destroy],
                                     related_file_ids: [] })
    end
  end
end

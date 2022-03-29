module Calendar
  class ApplicationController < ::ApplicationController
    def find_event
      if params[:id].match(/^\d+\-?/)
        @event = current_site.events.find(params[:id])
      else
        @event = current_site.events.find_by(slug: params[:id])
      end
    end
  end
end

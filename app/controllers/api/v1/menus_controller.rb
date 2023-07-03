module API
  module V1
    class MenusController < BaseController
      before_action :authenticate_app

      def index
        params[:page] ||= 1
        site = Site.find_by id: params[:id]
        return not_found :site, params[:id] if !site

        @menus = site.menus
        render json: @menus
      end
    end
  end
end

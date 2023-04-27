module API
  module V1
    class ComponentsController < BaseController
      before_action :authenticate_app

      def index
        params[:page] ||= 1
        site = Site.find_by id: params[:id]
        return not_found :site, params[:id] if !site
        puts site

        render json: site.active_skin.root_components, root: 'data'
      end

    end
  end
end

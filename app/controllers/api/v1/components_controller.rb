module API
  module V1
    class ComponentsController < BaseController
      before_action :authenticate_app

      def index
        params[:page] ||= 1
        site = Site.find_by id: params[:id]
        return not_found :site, params[:id] if !site

        render json: site.active_skin.root_components, root: 'data'
      end

      def update
        component = Component.find_by id: params[:id]
        if component.update_attributes(component_params)
          render json: component, root: 'data'
        else
          render json: {error: t('api.component_not_created'), message: component.errors.full_messages}, status: 403
        end
      end

      def component_params
        params.require(:component).permit(:publish)
      end

    end
  end
end

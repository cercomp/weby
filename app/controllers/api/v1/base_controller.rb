module API
  module V1
    class BaseController < API::APIController

      def root
        render json: {sites: api_v1_sites_path,
                      users: api_v1_find_user_path,
                      locales: api_v1_locales_path,
                      groupings: api_v1_groupings_path,
                      themes: api_v1_themes_path,
                      menus: api_v1_menus_path,
                      menu_items: api_v1_menu_items_path,
                      pages: api_v1_pages_path}, status: 200
      end

      protected

      # def authenticate_api_user
      #   token = request.headers['weby-access-token'] || params[:weby_access_token]
      #   # TODO
      #   render(json: {success: false, error: t('api.invalid_user')}, status: :unauthorized) unless @app
      # end

      def authenticate_app
        token = request.headers['weby-api-token'] || params[:weby_api_token]
        code = request.headers['weby-app-code'] || params[:weby_app_code]
        @app = App.find_by(api_token: token, code: code) if token.present? && code.present?
        render(json: {success: false, error: t('api.invalid_app')}, status: :unauthorized) unless @app
      end
    end
  end
end
module API
  module V1
    class BaseController < API::APIController

      def root
        render json: {sites: api_v1_sites_path,
                      users: api_v1_find_user_path,
                      locales: api_v1_locales_path,
                      themes: api_v1_themes_path}, status: 200
      end

      protected

      # def authenticate_api_user
      #   token = request.headers['weby-access-token'] || params[:weby_access_token]
      #   # TODO
      #   render(json: {success: false, error: t('api.invalid_user')}, status: :unauthorized) unless @app
      # end

      def authenticate_app
        token = request.headers['weby-api-token'] || params[:weby_api_token]
        @app = App.find_by(api_token: token) if token.present?
        render(json: {success: false, error: t('api.invalid_app')}, status: :unauthorized) unless @app
      end
    end
  end
end
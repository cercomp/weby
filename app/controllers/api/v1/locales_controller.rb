module API
  module V1
    class LocalesController < BaseController
      before_action :authenticate_app
      #before_action :authenticate_api_user, except: [:index, :show]

      def index
        locales = Locale.all
        render json: locales, root: :locales, meta: build_meta(locales)
      end

    end
  end
end

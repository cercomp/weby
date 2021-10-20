module API
  module V1
    class ThemesController < BaseController
      before_action :authenticate_app
      #before_action :authenticate_api_user, except: [:index, :show]

      def index
        themes = Weby::Themes.all.reject{|th| th.is_private }.sort_by(&:name)
        render json: themes, root: :themes, meta: build_meta(themes)
      end

    end
  end
end

module API
  module V1
    class UsersController < BaseController
      before_action :authenticate_app
      #before_action :authenticate_api_user, except: [:index, :show, :transmissions, :create]

      def find
        if params[:email].present? || params[:login].present?
          query = {
            email: (params[:email] if params[:email].present?),
            login: (params[:login] if params[:login].present?)
          }.compact
          user = User.find_by query
          render json: {found: user.present?, user: user}
        else
          render json: {error: t('api.params_missing', param: "email | login"), message: ''}, status: 403
        end
      end
    end
  end
end

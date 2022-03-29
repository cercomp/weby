module API
  module V1
    class GroupingsController < BaseController
      before_action :authenticate_app
      #before_action :authenticate_api_user, except: [:index, :show]

      def index
        groupings = Grouping.all
        render json: groupings, root: :groupings, meta: build_meta(groupings)
      end

    end
  end
end

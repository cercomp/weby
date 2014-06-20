class Sites::Admin::StatisticsController < ApplicationController
  include DateHelper
  before_action :require_user
  before_action :check_authorization

  respond_to :html, :json

  def index
    respond_to do |format|
      format.html do
        @years, @months = map_months_from_date current_site.views.minimum(:created_at)
      end
      format.json do
        case params[:type]
        when 'day'
          render json: View.daily_stats(params[:filter_month].split('/')[1], params[:filter_month].split('/')[0], params[:metric], current_site.id)
        when 'month'
          render json: View.monthly_stats(params[:filter_year], params[:metric], current_site.id)
        end
      end
    end
  end
end

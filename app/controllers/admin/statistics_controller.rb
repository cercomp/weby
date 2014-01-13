class Admin::StatisticsController < ApplicationController
  before_filter :require_user
  before_filter :is_admin

  respond_to :html, :json

  def index
    respond_to do |format|
      format.html do
        min_date = View.minimum(:created_at)
        @years = min_date ? Time.now.year.downto(min_date.year).to_a : [Time.now.year]
        @months = []
        curr_date, oldest_date = Date.current, min_date ? min_date.to_date : Date.current
        while curr_date.month >= oldest_date.month && curr_date.year >= oldest_date.year
          @months << [l(curr_date, format: :monthly), curr_date.strftime('%m/%Y')]
          curr_date -= 1.month
        end
      end
      format.json do
        case params[:type]
        when 'day'
          render json: View.daily_stats(params[:filter_month].split('/')[1], params[:filter_month].split('/')[0], params[:metric], params[:site_id])
        when 'month'
          render json: View.monthly_stats(params[:filter_year], params[:metric], params[:site_id])
        end
      end
    end
  end

end

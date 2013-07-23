class Admin::StatisticsController < ApplicationController
  
  respond_to :html, :json
  
  def index
    respond_to do |format|
      format.html
      format.json{ render json: View.parsed_json(params[:site_id]) }
    end
  end

end

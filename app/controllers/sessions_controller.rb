class SessionsController < Devise::SessionsController
  layout 'weby_sessions'

  before_filter :store_location, only: :new

  private

  def store_location
    session[:return_to] = params[:back_url]
  end
end

class SessionsController < Devise::SessionsController
  layout 'weby_sessions'

  before_filter :store_location, only: :new

  after_filter :record_login, only: :create

  private

  def record_login
    string = request.user_agent
    user_agent = UserAgent.parse(string) 

    @history = UserLoginHistory.new
    @history.user_id = current_user.id
    @history.login_ip = request.remote_ip
    @history.browser = user_agent.browser
    @history.platform = user_agent.browser + " " + user_agent.os
    @history.save
  end

  def store_location
    session[:return_to] = params[:back_url]
  end
end

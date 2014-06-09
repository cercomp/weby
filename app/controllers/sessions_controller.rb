class SessionsController < Devise::SessionsController
  layout 'weby_sessions'

  before_action :store_location, only: :new

  after_filter :record_login, only: :create

  private

  def record_login
    string = request.user_agent
    user_agent = UserAgent.parse(string) 

    UserLoginHistory.create(user_id: current_user.id,
                            login_ip: request.remote_ip,
                            browser: user_agent.browser,
                            platform: "#{user_agent.platform} #{user_agent.os}")
  end

  def store_location
    session[:return_to] = params[:back_url]
  end
end

class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def shibboleth
    puts request.env["omniauth.auth"]

  #   user = User.create!(login: "User#{rand(99999)}",
  #     password: "User#{rand(99999)}",
	  # 	email: request.headers['HTTP_SHIB_INETORGPERSON_MAIL'],
  #     first_name: request.headers['HTTP_SHIB_INETORGPERSON_CN'],
	  # 	last_name: request.headers['HTTP_SHIB_INETORGPERSON_SN'],
  #     confirmed_at: Time.now,
  #     confirmation_sent_at: Time.now)
  #   AuthSource.create!(user_id: user.id,
  #     source_type: 'shibboleth',
  #     source_login: user.login)
  #   sign_in user
  # record_login
    redirect_to edit_profile_path user.login || root_path
  end

  private

  def record_login
    string = request.user_agent
    user_agent = UserAgent.parse(string)

    UserLoginHistory.create(user_id: current_user.id,
                            login_ip: request.remote_ip,
                            browser: user_agent.browser,
                            platform: "#{user_agent.platform} #{user_agent.os}")
  end
end

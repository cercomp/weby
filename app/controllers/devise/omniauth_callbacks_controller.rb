class Devise::OmniauthCallbacksController < DeviseController
  prepend_before_action { request.env["devise.skip_timeout"] = true }

  def shibboleth
    user = User.create!(login: "User#{rand(99999)}",
      password: "User#{rand(99999)}",
			email: request.headers['HTTP_SHIB_INETORGPERSON_MAIL'],
      first_name: request.headers['HTTP_SHIB_INETORGPERSON_CN'],
			last_name: request.headers['HTTP_SHIB_INETORGPERSON_SN'],
      confirmed_at: Time.now,
      confirmation_sent_at: Time.now)
    AuthSource.create!(user_id: user.id,
      source_type: 'shibboleth',
      source_login: user.login)
    sign_in user
		record_login
    redirect_to edit_profile_path user.login || root_path
  end

  def passthru
    render status: 404, text: "Not found. Authentication passthru."
  end

  def failure
    set_flash_message :alert, :failure, kind: OmniAuth::Utils.camelize(failed_strategy.name), reason: failure_message
    redirect_to after_omniauth_failure_path_for(resource_name)
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

  protected

  def failed_strategy
    request.respond_to?(:get_header) ? request.get_header("omniauth.error.strategy") : env["omniauth.error.strategy"]
  end

  def failure_message
    exception = request.respond_to?(:get_header) ? request.get_header("omniauth.error") : env["omniauth.error"]
    error   = exception.error_reason if exception.respond_to?(:error_reason)
    error ||= exception.error        if exception.respond_to?(:error)
    error ||= (request.respond_to?(:get_header) ? request.get_header("omniauth.error.type") : env["omniauth.error.type"]).to_s
    error.to_s.humanize if error
  end

  def after_omniauth_failure_path_for(scope)
    new_session_path(scope)
  end

  def translation_scope
    'devise.omniauth_callbacks'
  end
end

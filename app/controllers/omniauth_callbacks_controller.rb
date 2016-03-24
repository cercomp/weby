class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def shibboleth
    auth_hash = get_vars

    user = User.find_by email: auth_hash[:mail]

    if user
      redir = session[:return_to] || root_path
    else
      user = User.create!(
        login: "User#{rand(99999)}",
        password: "User#{rand(99999)}",
        email: auth_hash[:mail],
        first_name: auth_hash[:name],
        last_name: auth_hash[:last_name],
        confirmed_at: Time.now,
        confirmation_sent_at: Time.now
      )
      AuthSource.create!(
        user_id: user.id,
        source_type: 'shibboleth',
        source_login: user.login
      )
      redir = edit_profile_path(user.login) || root_path
    end
    sign_in user
    user.record_login(request.user_agent, request.remote_ip)
    redirect_to redir
  end

  private

  def get_vars
    {
      mail: request.headers['HTTP_SHIB_INETORGPERSON_MAIL'],
      name: request.headers['HTTP_SHIB_INETORGPERSON_CN'],
      last_name: request.headers['HTTP_SHIB_INETORGPERSON_SN']
    }
  end
end

class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def shibboleth
    auth_hash = get_vars

    user = User.find_by(email: auth_hash[:mail]) || User.new(
      login: "User#{rand(99999)}",
      password: "User#{rand(99999)}",
      email: auth_hash[:mail],
      first_name: auth_hash[:name],
      last_name: auth_hash[:last_name],
      confirmed_at: Time.now,
      confirmation_sent_at: Time.now
    )

    auth_source = user.auth_sources.find_by(source_type: 'shibboleth') || user.auth_sources.new(source_type: 'shibboleth')
    auth_source.update source_login: generate_code_for(user)

    if user.persisted?
      redir = session[:return_to] || root_path
    else
      redir = edit_profile_path(user.login) || root_path
      user.save!
    end
    redirect_to shib_login_url(auth_source.source_login, host: Weby::Settings::Cafe.login_host, back_url: redir)
  end

  private

  def generate_code_for user
    loop do
      code_candidate = SecureRandom.hex(16)
      break code_candidate unless user.auth_sources.find_by source_type: 'shibboleth', source_login: code_candidate
    end
  end

  def get_vars
    {
      mail: request.headers['HTTP_SHIB_INETORGPERSON_MAIL'].to_s.downcase,
      name: request.headers['HTTP_SHIB_INETORGPERSON_CN'].to_s.titleize,
      last_name: request.headers['HTTP_SHIB_INETORGPERSON_SN'].to_s.titleize
    }
  end
end

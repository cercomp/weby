class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def shibboleth
    auth_hash = get_vars

    user = User.find_by(email: auth_hash[:mail]) || User.new(
      login: "User#{rand(999999)}",
      password: "User#{rand(999999)}",
      email: auth_hash[:mail],
      first_name: auth_hash[:name],
      last_name: auth_hash[:last_name],
      confirmed_at: Time.current,
      confirmation_sent_at: Time.current
    )

    redir = if user.persisted?
      session[:return_to] || root_path
    else
      user.save!
      edit_profile_path(user.login)
    end

    auth_source = user.auth_sources.find_or_create_by(source_type: 'shibboleth')
    auth_source.update source_login: generate_code_for(user)

    host = Weby::Settings::Cafe.login_host
    redirect_to shib_login_url(auth_source.source_login, host: host, protocol: host.match(/^https?:\/\//).to_s, back_url: redir)
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
      mail: read_header('HTTP_SHIB_INETORGPERSON_MAIL', :downcase),
      name: read_header('HTTP_SHIB_INETORGPERSON_CN', :titleize),
      last_name: read_header('HTTP_SHIB_INETORGPERSON_SN', :titleize)
    }
  end

  def read_header name, process
    request.headers[name].to_s.dup.mb_chars.send(process).to_s
  end
end

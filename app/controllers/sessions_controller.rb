class SessionsController < Devise::SessionsController
  require 'net-ldap'

  layout 'weby_sessions'

  before_action :store_location, only: :new

  def create
    ldap = Weby::Settings::Ldap
    if ldap.host.nil?
      # caso LDAP não esteja configurado
      super
      current_user.record_login(request.user_agent, request.remote_ip) if current_user
    else
      # Caso LDAP esteja configurado na aplicação
      ldap_user_login = params[:user][:auth]
      ldap_user_pass = ldap.prefixo.to_s + Digest::SHA1.base64digest(params[:user][:password]) + ldap.sufixo.to_s
      if ldap.ldaps.to_s == 'true'
        connect = Net::LDAP.new host: ldap.host,
          port: ldap.port,
          encryption: :simple_tls,
          auth: {
            method: :simple,
            username: ldap.account,
            password: ldap.account_password
          }
      else
        connect = Net::LDAP.new host: ldap.host,
          port: ldap.port,
          auth: {
            method: :simple,
            username: ldap.account,
            password: ldap.account_password
          }
      end
      filter = Net::LDAP::Filter.join(Net::LDAP::Filter.eq(ldap.attr_login, ldap_user_login), Net::LDAP::Filter.eq(ldap.attr_password, ldap_user_pass))
      ldap_user = connect.search(:base => ldap.base, :filter => filter)
      if ldap_user.first.nil?
        # Caso as credenciais não sejam autenticadas no LDAP
        super
        current_user.record_login(request.user_agent, request.remote_ip) if current_user
      else
        # Caso o login seja bem sucedido no LDAP
        source = AuthSource.find_by(source_type: 'ldap', source_login: ldap_user_login)
        if source.nil?
          # Caso o login no LDAP ainda não esteja vinculado a nenhuma conta no Weby
          session[:ldap_login] = ldap_user.first[ldap.attr_login].first.to_s
          session[:ldap_first_name] = ldap_user.first[ldap.attr_firstname].first.to_s
          session[:ldap_last_name] = ldap_user.first[ldap.attr_lastname].first.to_s
          session[:ldap_email] = ldap_user.first[ldap.attr_mail].first.to_s
          session[:ldap_type] = 'ldap'
          flash[:success] = t('ldap_login_sucess', login: ldap_user_login)
          flash[:warning] = t('link_weby_user')
          @session = User.new
          @confirm = 'true'
          #@show_new_user = User.find_by_login(ldap_user_login).blank?
          @name_suggested = ldap_user_login;
          render :new
        else
          # Caso o auth source desse login no LDAP já esteja vinculado a uma conta Weby
          if ldap.force_ldap_login.to_s == 'true'
            source.user.clear_password!
          end
          sign_in source.user
          source.user.record_login(request.user_agent, request.remote_ip)
          redirect_to session[:return_to] || root_path
        end
      end
    end
  end

  def shib_login
    auth_source = AuthSource.find_by source_login: params[:hash], source_type: 'shibboleth'
    if auth_source
      sign_in auth_source.user
      auth_source.user.record_login(request.user_agent, request.remote_ip)
      auth_source.update source_login: nil
      redirect_to params[:back_url] || root_path
    else
      flash[:error] = t('shib_invalid')
      redirect_to login_path
    end
  end

  def link_user
    user = User.find_by_login(params[:user][:auth])
    if user.nil? || !user.valid_password?(params[:user][:password])
      flash[:error] = t('invalid')
      redirect_to login_path(confirm: 'true')
    else
      AuthSource.new(user_id: user.id, source_type: session[:ldap_type], source_login: session[:ldap_login]).save!
      if Weby::Settings::Ldap.force_ldap_login.to_s == 'true'
        user.clear_password!
      end
      sign_in user
      user.record_login(request.user_agent, request.remote_ip)
      redirect_to session[:return_to] || root_path
    end
  end

  def new_user
    if session[:ldap_login].blank? || session[:ldap_email].blank?
      flash[:error] = t('invalid')
      redirect_to login_path
    else
      user = User.new(
        login: session[:ldap_login],
        email: session[:ldap_email],
        password: "A#{SecureRandom.hex(32)}",
        sign_in_count: 1,
        current_sign_in_at: Time.current,
        last_sign_in_at: Time.current,
        current_sign_in_ip: '127.0.0.1',
        last_sign_in_ip: '127.0.0.1',
        first_name: session[:ldap_first_name],
        last_name: session[:ldap_last_name],
        confirmed_at: Time.current,
        confirmation_sent_at: Time.current)
      user.save!
      AuthSource.new(user_id: user.id, source_type: session[:ldap_type], source_login: session[:ldap_login]).save!
      sign_in user
      user.record_login(request.user_agent, request.remote_ip)
      redirect_to session[:return_to] || root_path
    end
  end

  private

  def store_location
    session[:return_to] = params[:back_url]
  end
end

class SessionsController < Devise::SessionsController
  require 'net-ldap'

  layout 'weby_sessions'

  before_action :store_location, only: :new

  def new
    if params[:cancel_ldap] == 'true'
      clear_ldap_session!
    elsif params[:confirm] == 'true' && session[:ldap_login].present?
      flash[:warning] = t('link_weby_user')
      @session = User.new
      @confirm = 'true'
      @name_suggested = session[:ldap_login]
      @cancelable = true
      @user_exists = User.exists?(email: session[:ldap_email])
    end
    super
  end

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
      #puts "---->>>>>>>>> #{ldap_user.first.inspect}"
      if ldap_user.first.nil?
        # Caso não logou no LDAP -> tenta logar no banco
        auth_user = User.find_by_login(params[:user][:auth])
        if auth_user && auth_user.valid_password?(params[:user][:password])
          # Logado
          sign_in auth_user
          current_user.record_login(request.user_agent, request.remote_ip)
          set_flash_message!(:notice, :signed_in)
          respond_with resource, location: after_sign_in_path_for(resource)
        else
          if ldap.force_ldap_login.to_s == 'true' && AuthSource.exists?(source_type: 'ldap', source_login: ldap_user_login)
            flash[:warning] = t('user_has_link')
          end
          flash[:alert] = t(:invalid)
          redirect_to login_path
        end
      else
        # Caso o login seja bem sucedido no LDAP
        source = AuthSource.find_by(source_type: 'ldap', source_login: ldap_user_login)
        if source.nil?
          # Caso o login no LDAP ainda não esteja vinculado a nenhuma conta no Weby
          session[:ldap_login] = ldap_user.first[ldap.attr_login].first.to_s
          session[:ldap_first_name] = ldap_user.first[ldap.attr_firstname].first.to_s
          session[:ldap_last_name] = ldap_user.first[ldap.attr_lastname].first.to_s
          session[:ldap_email] = ldap.email_domain.present? ? "#{session[:ldap_login]}#{ldap.email_domain}" : ldap_user.first[ldap.attr_mail].first.to_s
          session[:ldap_type] = 'ldap'
          flash[:success] = t('ldap_login_sucess', login: ldap_user_login)
          flash[:warning] = t('link_weby_user')
          @session = User.new
          @confirm = 'true'
          @name_suggested = ldap_user_login;
          @user_exists = User.exists?(email: session[:ldap_email])
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
    elsif user.email != session[:ldap_email]
      flash[:error] = t('ldap_email_invalid')
      redirect_to login_path(confirm: 'true')
    else
      AuthSource.new(user_id: user.id, source_type: session[:ldap_type], source_login: session[:ldap_login]).save!
      if Weby::Settings::Ldap.force_ldap_login.to_s == 'true'
        user.clear_password!
      end
      sign_in user
      user.record_login(request.user_agent, request.remote_ip)
      clear_ldap_session!
      redirect_to session[:return_to] || root_path
    end
  end

  def new_user
    if session[:ldap_login].blank? || session[:ldap_email].blank?
      flash[:error] = t('invalid')
      redirect_to login_path
    else
      if User.exists?(email: session[:ldap_email])
        flash[:error] = t('ldap_user_exists')
        redirect_to login_path(confirm: 'true')
      else
        _login = "#{session[:ldap_login]}#{'1' if User.exists?(login: session[:ldap_login])}"
        user = User.new(
          login: _login,
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
        clear_ldap_session!
        redirect_to session[:return_to] || root_path
      end
    end
  end

  private

  def clear_ldap_session!
    session.delete :ldap_login
    session.delete :ldap_first_name
    session.delete :ldap_last_name
    session.delete :ldap_email
    session.delete :ldap_type
  end

  def store_location
    session[:return_to] = params[:back_url]
  end
end

class PasswordsController < Devise::PasswordsController

  # POST /resource/password
  def create
    user = resource_class.find_by email: params[:user][:email]
    if user.present? && user.ldap_auth_source.present? && Weby::Settings::Ldap.force_ldap_login.to_s == 'true'
      flash[:error] = t('ldap_only_user')
      redirect_to forgot_password_path
    else
      super
    end
  end

end

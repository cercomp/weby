class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale
  before_filter :check_authorization, :except => [:current_user_session, :current_user, :access_denied, :choose_layout]
 
  helper :all
  helper_method :current_user_session, :current_user, :user_not_authorized

  def choose_layout
    if current_user && !current_user.theme.empty?
      return current_user.theme
    elsif current_user && !current_user.role_ids.empty?
      role_theme = Role.find(current_user.role_ids.to_s).theme
      unless role_theme.nil? or role_theme.empty?
        return role_theme
      end
    end
    return "application"
  end

  def check_authorization
    if current_user
      if current_user.is_admin
        return true
      end
      u = User.find(current_user.id)
      unless u.roles.detect do |role|
        role.rights.detect do |right|
            right.action.split(' ').detect do |ri| 
              ri == action_name && right.controller == self.class.controller_path 
            end
          end
        end
        flash[:error] = t:access_denied_page
        request.env["HTTP_REFERER" ] ? (redirect_to :back) : (render :template => 'admin/access_denied')
        #(render :template => 'admin/access_denied')
        return false
      end
    else
        request.env["HTTP_REFERER" ] ? (redirect_to :back) : (render :template => 'admin/access_denied')
        #(render :template => 'admin/access_denied')
    end
  end

  def set_locale
    # I18n.default_locale returns the current default locale. Defaults to 'en-US'
    I18n.load_path += Dir[ File.join(Rails.root, 'lib', 'locale', '*.{rb,yml}') ]
    locale = params[:locale] || session[:locale] || I18n.default_locale
    session[:locale] = I18n.locale = locale
  end

  def access_denied
    if current_user
      render :template => 'admin/access_denied'
    else
      flash[:error] = 'Acesso negado. Tente logar primeiro.'
      redirect_to login_path
    end
  end

  # Retorna o papel do usuario
  def user_role_name(user)
    return RolesUser.find(:first, :select => "roles.name", :joins => "INNER JOIN users ON users.id=user_id INNER JOIN roles ON roles.id=role_id", :conditions => [ "users.id = ?", user.id ], :order => "role_id")
  end

  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
    
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
    
  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to account_url
      return false
    end
  end
    
  def store_location
    session[:return_to] = request.request_uri
  end
    
  def redirect_back_or_default(default)
    if default
      redirect_to(default)
    else
      redirect_to :back
    end
  end
end

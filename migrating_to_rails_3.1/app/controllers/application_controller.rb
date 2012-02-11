# coding: utf-8
class ApplicationController < ActionController::Base
  include ApplicationHelper # Para usar helper methods nos controllers
  protect_from_forgery
  before_filter :set_contrast, :set_locale, :set_global_vars

  helper :all
  helper_method :current_user_session, :current_user, :user_not_authorized, :sort_direction

  def choose_layout
    if @site.nil? or @site.id.nil? 
      return "application"
    else
      if @site.theme
        return @site.theme
        # Tentar usar tema definido no perfil do usuário
      elsif current_user && !current_user.theme.empty?
        return current_user.theme
        # Se não existir tente o definido no papel do usuário
      elsif current_user && !current_user.role_ids.empty?
        role_theme = Role.find(current_user.role_ids).theme
        unless role_theme.nil? or role_theme.empty?
          return role_theme
        end
      end
    end
    # Se não for nenhum dos acima use este
    return "this2"
  end

  def check_authorization
    return false unless current_user
    return true if current_user.is_admin
    unless get_roles(current_user).detect do |role|
        role.rights.detect do |right|
          right.action.split(' ').detect do |ri| 
            right.controller == self.class.controller_path && ri == action_name
          end
        end
      end
      flash[:error] = t("access_denied")
      #request.env["HTTP_REFERER" ] ? (redirect_to :back) : (render :template => 'admin/access_denied')
      (render :template => 'admin/access_denied', :status => :forbidden)
      return false
    end
  end

  def set_contraste
    contraste = params[:contraste] || session[:contraste]
    session[:contraste] = 'no'
  end

  def set_locale
    # I18n.load_path += Dir[ File.join(Rails.root, 'lib', 'locale', '*.{rb,yml}') ]
    locale = params[:locale] || session[:locale] || I18n.default_locale
    @current_locale = session[:locale] = I18n.locale = locale
  end

  def set_contrast
    session[:contrast] = params[:contrast] || session[:contrast] || 'no'
  end

  def access_denied
    if current_user
      flash.now[:error] = t("acess_denied")
    else
      flash.now[:error] = t("try_login")
    end
    redirect_back_or_default login_path
  end

  # Método utilizado para redirecionamento, quando endereço não existe
  def catcher
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end

  private
  
  def is_admin
    unless current_user.is_admin
      flash[:error] = t"only_admin"
      redirect_to :back
    else 
      return true
    end
  end

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
      flash[:error] = t("need_login")
      redirect_to new_user_session_url(:back_url => "#{params[:back_url]}")
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:error] = t("no_need_to_login")
      redirect_to users_url
      return false
    end
  end

  def store_location
    #session[:return_to] = request.fullpath if request.get? and controller_name != "user_sessions" and controller_name != "sessions"
    session[:return_to] = request.fullpath
    session[:return_to] ||= request.referer
  end

  #  def redirect_back_or_default(default)
  #    back_url = CGI.unescape(params[:back_url].to_s)
  #    if !back_url.blank?
  #      begin
  #        uri = URI.parse(back_url)
  #        # do not redirect user to another host or to the login or register page
  #        if (uri.relative? || (uri.host == request.host)) && !uri.path.match(%r{/(login|account/register)})
  #          redirect_to(back_url)
  #          return
  #        end
  #      rescue URI::InvalidURIError
  #        # redirect to default
  #      end
  #    end
  #    if session[:return_to] && !session[:return_to].match(%r{/(login|user_sessions/new)}).nil?
  #      redirect_to(session[:return_to])
  #    else
  #      redirect_to(default)
  #    end
  #    session[:return_to] = nil
  #  end

  def redirect_back_or_default(default)
    session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
    session[:return_to] = nil
  end

  # Defini variáveis globais
  def set_global_vars
    if params[:site_id]
      @site = Site.find_by_name(params[:site_id])
    elsif params[:id]
      @site = Site.find_by_name(params[:id])
    end

    if @site
      params[:per_page] ||= per_page_default

      # Agrupa todos os menus do site pelo "category" definido
      @menus = @site.sites_menus.group_by(&:category)

      # Agrupa os menu afi de deixar os submenus organizados.
      #   Exemplo: menu['principal'] = { 0 => [menu1, menu2], 1 => [menu3, menu4] }
      @menus.each{ |key,value| @menus[key] = value.group_by(&:parent_id) || "" }

      if not @site.repository.nil? and File.file?(@site.repository.archive.path) and @site.repository.image?
        @top_banner_width,@top_banner_height = Paperclip::Geometry.from_file(@site.repository.archive).to_s.split('x')
      end
    end

    @main_width = nil
    if @site and @site.try(:body_width)
      @main_width = @site.body_width.to_i
    elsif @site and @top_banner_width
      @main_width = @top_banner_width.to_i
    end
  end

  # Metodo usado na ordenação de tabelas por alguma coluna
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  

end

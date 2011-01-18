# coding: utf-8
require 'pp'
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale, :get_site_obj
 
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
    return "this2html5"
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
        flash[:error] = t("access_denied")
        #request.env["HTTP_REFERER" ] ? (redirect_to :back) : (render :template => 'admin/access_denied')
        (render :template => 'admin/access_denied')
        return false
      end
    end
  end

  def set_locale
    # I18n.load_path += Dir[ File.join(Rails.root, 'lib', 'locale', '*.{rb,yml}') ]
    locale = params[:locale] || session[:locale] || I18n.default_locale
    session[:locale] = I18n.locale = locale
  end

  def access_denied
    if current_user
      flash.now[:error] = t("acess_denied")
    else
      flash.now[:error] = t("try_login")
    end
    redirect_back_or_default login_path
  end
  # Metodo para tratar o menu
  def menu_treat(obj)
    result = []
    #obj.sort!{|x,y| x.parent_id.to_i <=> y.parent_id.to_i }
    while not obj.empty?
      l = obj.shift
      result << l 
      result_test = search_son(l.id, obj)
      result << result_test unless result_test.empty?
    end
    return result
  end
  # Procura pelo id de um filho (id) em um dado vetor (arr)
  def search_son(id, arr)
    result = []
    i = 0 
    while i < arr.size
      a = arr[i]
      if id.to_i == a.parent_id.to_i
        result << arr.delete(a)
        result_test = search_son(a.id, arr)
        result << result_test unless result_test.empty?
      else
        i += 1
      end 
    end 
    return result
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
      flash[:error] = t("need_login")
      redirect_to new_user_session_url
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
    session[:return_to] = request.fullpath
    #session[:return_to] = request.request_uri if request.get? and controller_name != "user_sessions" and controller_name != "sessions"
    #session[:return_to] ||= request.referer
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
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  # Pegar o id do site a partir do seu nome
  def get_site_obj
    if params[:site_id]
      if params[:site_id].match(/^[0-9]+$/)
        @site = Site.find(:first, :conditions => ["id = ?", params[:site_id]])
      else
        @site = Site.find(:first, :conditions => ["name = ?", params[:site_id]])
      end

      top_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.side,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.side = 'top' AND sites_menus.site_id = #{@site.id} ORDER BY sites_menus.parent_id,sites_menus.position")
      left_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.side,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.side = 'left' AND sites_menus.site_id = '#{@site.id}' ORDER BY sites_menus.parent_id,sites_menus.position")
      right_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.side,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.side = 'right' AND sites_menus.site_id = #{@site.id} ORDER BY sites_menus.parent_id,sites_menus.position")
      bottom_untreated = Site.find_by_sql("SELECT sites_menus.id,menus.id as menu_id,menus.title,menus.link,sites_menus.parent_id,sites_menus.side ,sites_menus.position FROM menus INNER JOIN sites_menus ON sites_menus.menu_id=menus.id WHERE sites_menus.side = 'bottom' AND sites_menus.site_id = #{@site.id} ORDER BY sites_menus.parent_id,sites_menus.position")
      
      @par_left = left_untreated.group_by(&:parent_id)
      @par_top = top_untreated.group_by(&:parent_id)
      
      @left = menu_treat(left_untreated)
      @right = menu_treat(right_untreated)
      @top = menu_treat(top_untreated)
      @bottom = menu_treat(bottom_untreated)
    elsif params[:id]
      @site = Site.find(:first, :conditions => ["name = ?", params[:id]])
    end
  end
end

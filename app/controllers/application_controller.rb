# coding: utf-8
class ApplicationController < ActionController::Base
  include ApplicationHelper # Para usar helper methods nos controllers
  include UrlHelper #Para utilizar url_helper que trata o subdomínio para Sites
  protect_from_forgery
  before_filter :set_contrast, :set_locale, :set_global_vars, :set_view_types
  after_filter :clear_weby_cache, :count_view

  helper :all
  helper_method :current_user_session, :current_user, :sort_direction, :test_permission,
    :current_locale, :current_site, :current_settings, :current_roles_assigned, :component_is_available

  def admin
    render 'admin/admin'
  end

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
    unless test_permission(self, action_name)
      respond_to do |format|
        format.json { render json: {errors: [t("access_denied.access_denied")]}, :status => :forbidden }
        format.any { render :template => 'session/access_denied', :status => :forbidden }
      end
    end
  end

  def test_permission(ctrl, action)
    return false unless current_user
    return true if current_user.is_admin
    ctrl = ctrl.controller_name if ctrl.respond_to? :controller_name
    return @current_rights.fetch(ctrl.to_sym, {}).fetch(action.to_sym, false)
  end

  def set_contrast
    session[:contrast] = params[:contrast] || session[:contrast] || 'no'
  end

  def set_view_types
    session[:repository_view] = params[:repository_view] || session[:repository_view] || 'thumbs'
    session[:banners_view] = params[:banners_view] || session[:banners_view] || 'list'
  end

  def current_site
    case
    when defined?(@current_site)
      return @current_site
    when Weby::Subdomain.matches?(request)
      #search subsites
      sites = Weby::Subdomain.site_id.split('.')
      @current_site = Site.where(parent_id: nil).find_by_name(sites[-1])
      if(sites.length == 2)
        @current_site = @current_site.subsites.find_by_name(sites[-2]) if @current_site
      end
      @current_site if [1,2].include? sites.length
    end
  end

  # Return Settings as a Hash object
  def current_settings
    @current_settings ||= (Weby::Cache.request[:settings] ||= Hash[Setting.all.map{|st| [st.name.to_sym,st.value] }])
  end

  def locale_key
    is_in_admin_context? ? :admin : current_site ? current_site.id : 0
  end

  def set_locale
    session[:locales] ||= {}
    locale = (is_in_admin_context? ? current_user.try(:locale).try(:name) : params[:locale] || session[:locales][locale_key]) || I18n.default_locale
    @current_locale = session[:locales][locale_key] = I18n.locale = locale if locale != @current_locale
  end

  def current_locale
    @current_locale
  end

  def access_denied
    if current_user
      flash.now[:error] = t("acess_denied")
    else
      flash.now[:error] = t("try_login")
    end
    redirect_back_or_default login_url(subdomain: nil, protocol: login_protocol)
  end

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from ActionController::UnknownAction, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end

  @@weby_error_logger = Logger.new("#{Rails.root}/log/error.log")

  # Método utilizado para redirecionamento, quando endereço não existe
  def render_404(exception=nil)
    @not_found_path = request.path
    @error = exception
    respond_to do |format|
      format.html { render template: 'errors/404', layout: 'application', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def render_500(exception)
    @error = exception
    @error_code = (Time.now.to_f*10).to_i
    @@weby_error_logger.error("{#{@error_code}:#{Time.now}\n"+
        "#{current_site.title if current_site}\n"+
        "#{exception.class}\n"+
        "#{exception.message}\n"+
        "#{filter_backtrace(exception).join("\n")}\n"+
        "#{request.host_with_port}#{request.fullpath}\n"+
        "#{params}\n"+
        "}")
    respond_to do |format|
      format.html { render template: 'errors/500', layout: 'application', status: 500 }
      format.all { render nothing: true, status: 500}
    end
  end

  def count_view
    return if is_in_admin_context? or
              !current_site or
              request.format != 'html' or
              response.status != 200 or
              Weby::Bots.is_a_bot?(request.user_agent)

    current_site.views.create(viewable: @page,
                              ip_address: request.remote_ip,
                              referer: request.referer,
                              user: current_user,
                              query_string: request.query_string,
                              request_path: request.path,
                              user_agent: request.user_agent,
                              session_hash: request.session_options[:id])
    Page.increment_counter :view_count, @page.id if @page
    Site.increment_counter :view_count, current_site.id
  end

  def count_click
    params[:model].titleize.constantize.increment_counter :click_count, params[:id]
    render nothing: true
  end

  private

  def filter_backtrace(exception)
    if backtrace = exception.backtrace
      if defined?(Rails.root)
        backtrace.map { |line| line.include?(Rails.root.to_s) ? line.sub(Rails.root.to_s, '') : nil }.compact
      else
        backtrace
      end
    end
  end

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

  def current_roles_assigned
    return [] unless current_user
    if @site
      # Obtém todos os papéis do usuário relacionados com site
      @current_roles_assigned ||= current_user.roles.where(['site_id IS NULL OR site_id = ?', @site.id])
    else
      # Obtém os papéis globais
      @current_roles_assigned ||= current_user.roles.where(site_id: nil)
    end
  end

  def require_user
    unless current_user
      store_location
      flash[:error] = t("need_login")
      redirect_to login_url(subdomain: nil, protocol: login_protocol, back_url: "#{request.protocol}#{request.host_with_port}#{request.path}")
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      #flash[:error] = t("no_need_to_login")
      redirect_to admin_path
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
    @site = current_site

    params[:per_page] ||= per_page_default

    @current_rights = {}
    current_roles_assigned.each do |role|
      role.rights.each do |right|
        right.action.split(' ').each do |action|
          (@current_rights[right.controller.to_sym] ||= {})[action.to_sym] = true
        end
      end
    end
    #puts @my_rights

    if is_in_admin_context?
      #alguma var global exclusiva para o backend
    else
      if @site

        @global_menus = {}
        # Carrega os menus, para auemntar a eficiência, já que menus são carregados em todas as requisições
        @site.menus.with_items.each do |menu|
          @global_menus[menu.id] = menu
        end

        @global_components = {}
        @site.components.where({publish: true}).order('position asc').each do |comp|
          (@global_components[comp.place_holder.to_sym] ||= []) << comp if component_is_available comp.name
        end
        
        @main_width = nil
        if @site.try(:body_width)
          @main_width = @site.body_width.to_i
        end
      end
    end
  end

  def component_is_available comp_name
    if (comp = Weby::Components.components[comp_name.to_sym])
      if comp[:group] != :weby
        return false unless current_site.extensions.select{|extension| extension.name == comp[:group].to_s }.any?
      end
    end
    Weby::Components.is_enabled? comp_name
  end

  def clear_weby_cache
    Weby::Cache.request.clear
  end

  # Metodo usado na ordenação de tabelas por alguma coluna
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

end

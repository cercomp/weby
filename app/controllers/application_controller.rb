# coding: utf-8
class ApplicationController < ActionController::Base
  include ApplicationHelper # In order to user helper methods in controllers

  force_ssl if: :should_be_ssl?

  protect_from_forgery with: :exception

  before_action :set_tld_length, :set_global_vars
  before_action :set_contrast, :set_locale, :set_view_types
  before_action :maintenance_mode
  before_action :require_user, only: [:admin]
  before_action :configure_permitted_parameters, if: :devise_controller?

  after_action :weby_clear, :count_view

  helper :all
  helper_method :current_user_session, :sort_direction, :test_permission,
                :current_locale, :current_site, :current_settings, :current_roles_assigned, :component_is_available

  def admin
    render 'admin/admin'
  end

  def choose_layout
    current_site.theme
  end

  def check_authorization
    unless test_permission(self, action_name)
      respond_to do |format|
        format.json { render json: { errors: [t('access_denied.access_denied')] }, status: :forbidden }
        format.any { render template: 'admin/access_denied', status: :forbidden }
      end
    end
  end

  def test_permission(ctrl, action)
    return false unless current_user
    return true if current_user.is_admin || current_user.is_local_admin?(current_site)
    ctrl = ctrl.controller_name if ctrl.respond_to? :controller_name
    ctrl = ctrl.split('/')[-1] if ctrl.match(/^\w+\/\w+/)
    @current_rights.fetch(ctrl.to_sym, {}).fetch(action.to_sym, false)
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
      # search subsites
      @current_site = Weby::Subdomain.find_site
    end
  end

  # Return Settings as a Hash object
  def current_settings
    Weby::Settings::Weby
  end

  def locale_key
    not_in_site_context? ? :admin : current_site ? current_site.id.to_s : 0
  end

  def set_locale
    session[:locales] ||= {}
    locale = params[:locale] || session[:locales][locale_key] || I18n.default_locale
    locale = current_user.locale.try(:name) || locale if not_in_site_context? && current_user
    @current_locale = session[:locales][locale_key] = I18n.locale = locale if locale != @current_locale
  end

  attr_reader :current_locale

  def access_denied
    if current_user
      flash.now[:error] = t('acess_denied')
    else
      flash.now[:error] = t('try_login')
    end
    redirect_back_or_default weby_login_url
  end

  def set_tld_length
    if current_site && request.domain
      if Weby::Settings::Weby.domain.present? && !(request.domain.match(Weby::Settings::Weby.domain))
        request.session_options[:tld_length] = current_site.domain.split('.').length + 1 if current_site.domain
      end
    end
  end

  def should_be_ssl?
    current_user && Weby::Settings::Weby.login_protocol == 'https' && !request.ssl?
  end

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from ActionController::UnknownFormat, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end

  @@weby_error_logger = Logger.new("#{Rails.root}/log/error.log")
  @@weby_error_logger.formatter = ->(severity, datetime, progname, msg) { msg }

  # Redirection when the address does not exist
  def render_404(exception = nil)
    @not_found_path = request.path
    @error = exception
    respond_to do |format|
      format.html { render template: 'errors/404', layout: 'weby_pages', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def render_500(exception)
    @error = exception
    @error_code = (Time.now.to_f * 10).to_i
    @@weby_error_logger.error("{#{@error_code}:#{Time.now}\n"\
        "#{current_site.title if current_site}\n"\
        "#{exception.class}\n"\
        "#{exception.message}\n"\
        "#{filter_backtrace(exception).join("\n")}\n"\
        "#{request.host_with_port}#{request.fullpath} from #{request.remote_ip}\n"\
        "#{params}\n"\
        '}')
    respond_to do |format|
      format.html { render template: 'errors/500', layout: 'weby_pages', status: 500 }
      format.all { render nothing: true, status: 500 }
    end
  end

  def count_view
    #TODO This is only counting the global counter on each model, Stats are off for now
    return if is_in_admin_context? ||
              request.format != 'html' ||
              response.status != 200 ||
              Weby::Bots.is_a_bot?(request.user_agent)
    if(current_site)
#      current_site.views.create(viewable: @page,
#                                ip_address: request.remote_ip,
#                                referer: request.referer,
#                                user: current_user,
#                                query_string: request.query_string,
#                                request_path: request.path,
#                                user_agent: request.user_agent,
#                                session_hash: request.session_options[:id])
      Page.increment_counter :view_count, @page.id if @page
      Site.increment_counter :view_count, current_site.id
      Journal::News.increment_counter :view_count, @news.id if @news && @news.is_a?(Journal::News)
      Calendar::Event.increment_counter :view_count, @event.id if @event
    else
#      View.create(viewable: @page,
#                              ip_address: request.remote_ip,
#                              referer: request.referer,
#                              user: current_user,
#                              query_string: request.query_string,
#                              request_path: request.path,
#                              user_agent: request.user_agent,
#                              session_hash: request.session_options[:id])
    end
  end

  # NOTE Review this method to include the extensions
  def count_click
    case params[:model]
    when 'banner'
      Sticker::Banner.increment_counter :click_count, params[:id]
    else
      params[:model].titleize.constantize.increment_counter :click_count, params[:id]
    end
    render nothing: true
  end

  protected

  # carrega o recurso de um controller
  # ex: /users/2
  #
  # busca por um elemento @user (get_resource_ivar), caso ele já tenha sido carregado
  # caso seja null, ele seta essa variavel sempre com o padrão Model.find(params[:id])
  # para mudar o comportamento basta sobreescrever esse methodo, por exemplo:
  #
  # def resource
  #   get_resource_ivar || set_resource_ivar(self.controller_name.classify.constantize.send(:find_by_token, params[:token]))
  # end
  #
  # kudos para @josevalim em https://github.com/josevalim/inherited_resources
  def resource
    #get_resource_ivar || set_resource_ivar(controller_name.classify.constantize.send(:find, params[:id]))
    parts = controller_path.split('/')
    model_class = parts.delete_if{|part| part.match(/admin|sites/) && part != parts[-1] }.join('/')
    get_resource_ivar || set_resource_ivar(model_class.classify.constantize.send(:find, params[:id]))
  end

  # strong parameter to load in devise
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u|
      u.permit(:login, :email, :first_name, :last_name, :password,
               :password_confirmation)
    }
  end

  private

  # Search for a variable with the same name of the controller
  # eg. if it is the Users controller it will search for
  # @user
  def get_resource_ivar
    instance_variable_get("@#{controller_name.singularize}")
  end

  # Defines one variable with the same name of the controlller
  # eg. if it is the Users controller it will create
  # @user with the given param
  def set_resource_ivar(resource)
    instance_variable_set("@#{controller_name.singularize}", resource)
  end

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
    return true if current_user.is_admin
    flash[:error] = t'only_admin'

    begin
      redirect_to :back
    rescue
      redirect_to admin_path
    end
  end

  def global_local_admin
    return true if current_user.is_local_admin?(current_site.id) || current_user.is_admin
    flash[:error] = t'only_admin'

    begin
      redirect_to :back
    rescue
      redirect_to admin_path
    end
  end

  def current_user_session
    user_session
  end

  def current_roles_assigned
    return [] unless current_user
    if @site
      # Get all the user's roles related to a site
      @current_roles_assigned ||= current_user.roles.where(['site_id IS NULL OR site_id = ?', @site.id])
    else
      # Get the global roles
      @current_roles_assigned ||= current_user.roles.where(site_id: nil)
    end
  end

  def require_user
    authenticate_user!
  end

  def require_no_user
    if current_user
      store_location
      # flash[:error] = t("no_need_to_login")
      redirect_to admin_path
      return false
    end
  end

  def store_location
    session[:return_to] = request.fullpath || request.referer
  end

  def redirect_back_or_default(default)
    session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
    session[:return_to] = nil
  end

  # Defines global variables
  def set_global_vars
    @site = current_site

    Weby::Cache.request[:domain] = request.domain || request.remote_ip
    Weby::Cache.request[:subdomain] = request.subdomain
    Weby::Cache.request[:current_user] = current_user

    params[:per_page] ||= per_page_default

    @current_rights = {}
    current_roles_assigned.each do |role|
      if role.permissions != "Admin"
        role.permissions_hash.each do |controller, rights|
          rights.each do |right|
            Weby::Rights.actions(controller, right).each do |action|
              (@current_rights[controller.to_sym] ||= {})[action.to_sym] = true
            end
          end
        end
      end
    end

    if is_in_admin_context?
      # An global variable exclusive for the backend
    else
      if @site

        @global_menus = {}
        # Get the menus more efficiently, since menus are asked for in every requisition
        @site.menus.with_items.each do |menu|
          @global_menus[menu.id] = menu
        end

        components = @site.components.where(publish: true).order('position asc')
        comp_select = lambda { |place_holder|
          components.select { |comp| comp.place_holder == place_holder }.map do |component|
            comp = { component: component }
            if component.name == 'components_group'
              comp[:children] = comp_select.call(component.id.to_s)
            end
            comp
          end
        }

        @global_components = {}
        Weby::Themes.layout(@site.theme)['placeholders'].map { |place| place['names'] }.flatten.each do |place_holder|
          @global_components[place_holder.to_sym] = comp_select.call(place_holder)
        end

        @main_width = nil
        if @site.try(:body_width)
          @main_width = @site.body_width.to_i
        end
      end
    end
  end

  def component_is_available(comp_name)
    if (comp = Weby::Components.components[comp_name.to_sym])
      if comp[:group] != :weby
        return false unless current_site.extensions.select { |extension| extension.name == comp[:group].to_s }.any?
      end
    end
    Weby::Components.is_enabled? comp_name
  end

  def weby_clear
    Weby::Cache.request.clear
    Weby::Settings.clear
  end

  # Used to sort tables by any column
  def sort_direction
    %w(asc desc).include?(params[:direction]) ? params[:direction] : 'asc'
  end

  # NOTE overwrite devise url helpers
  def new_session_path(_arg)
    login_path
  end

  def after_sign_in_path_for(_args)
    session[:return_to] || root_path
  end

  def record_activity(note, loggeable)
    # real_ip = request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
    # if !ActivityRecord.where(user_id: current_user.id, site_id: current_site.id, controller: controller_name, action: action_name, loggeable: loggeable,
    @activity = ActivityRecord.new
    @activity.user_id = current_user.id
    @activity.site_id = current_site.id if current_site
    @activity.note = note
    @activity.browser = request.user_agent
    @activity.ip_address = request.remote_ip
    @activity.controller = controller_name
    @activity.action = action_name
    @activity.params = params.inspect
    @activity.loggeable = loggeable
    @activity.save!
    # end
  end

  def maintenance_mode
    if Weby::Settings::Weby.maintenance_mode == 'true' && !current_user.try(:is_admin?) && is_in_admin_context?
      render template: 'errors/maintenance', layout: 'weby_pages'
    end
  end
end

module Import
  class Application < Rails::Application
    CONVAR ||= {} # conversion variable, to translate de old repository_id to a new
    CONVAR["repository"] = {}
    CONVAR["menu"] = {}
  end
end

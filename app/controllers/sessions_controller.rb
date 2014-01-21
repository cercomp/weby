class SessionsController < Devise::SessionsController
  layout 'weby_sessions'

  before_filter :store_location, only: :new

  def new
    super
  end

  def create
    if Weby::Settings.maintenance_mode == "false"
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, :location => after_sign_in_path_for(resource)
    else
      #redirect_to pagina explicando
    end
  end

  private

  def store_location
    session[:return_to] = params[:back_url]
  end
end

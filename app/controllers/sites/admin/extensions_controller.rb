class Sites::Admin::ExtensionsController < ::ApplicationController
  before_action :require_user
  before_action :check_authorization

  def index
    @extensions = current_site.extensions
  end

  def new
    @extension = Extension.new
  end

  def create
    @extension = Extension.new params[:extension]
    @extension.site = current_site
    if @extension.save
      current_site.extensions << @extension
      redirect_to site_admin_extensions_path
    else
      render :new
    end
  end
  
  def destroy
    current_site.extensions.find(params[:id]).destroy
    redirect_to site_admin_extensions_path
  end
end

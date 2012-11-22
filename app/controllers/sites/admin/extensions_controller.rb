class Sites::Admin::ExtensionsController < ::ApplicationController
  before_filter :require_user
  before_filter :check_authorization

  def index
    @extensions = ['teachers', 'feedback']
    @extension = Extension.new
  end

  def create
    @extensions = ['teachers', 'feedback']
    @extension = Extension.new params[:extension]
    @extension.site = current_site
    if @extension.save
      current_site.extensions << @extension
      redirect_to site_admin_extensions_path
    else
      render :index
    end
  end
  
  def destroy
    current_site.extensions.find(params[:id]).destroy
    redirect_to site_admin_extensions_path
  end
end

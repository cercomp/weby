class Sites::Admin::ExtensionsController < ::ApplicationController
  before_action :require_user
  before_action :check_authorization

  def index
    @extensions = current_site.extensions
  end

  def edit
    @extension =  current_site.extensions.find(params[:id])
  end

  def update
  end

  def new
    @extension = Extension.new
  end

  def create
    @extension = current_site.extensions.new(extension_params)

    if @extension.save
      redirect_to site_admin_extensions_path
    else
      render :new
    end
  end

  def destroy
    current_site.extensions.find(params[:id]).destroy

    redirect_to site_admin_extensions_path
  end

  private

  def extension_params
    params.require(:extension).permit(:name)
  end
end

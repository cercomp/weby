class Sites::Admin::ExtensionsController < ::ApplicationController
  before_action :require_user
  before_action :check_authorization

  def index
    @extensions = current_site.active_extensions
  end

  def edit
    @extension =  current_site.extensions.find(params[:id])
  end

  def update
    @extension =  current_site.extensions.find(params[:id])
    if @extension.update(extension_update_params)
      redirect_to(site_admin_extensions_path,
                  flash: { success: t('successfully_updated_param', param: t('extension')) })
    else
      render action: 'edit'
    end
  end

  def new
    @extension = Extension.new
  end

  def create
    @extension = current_site.extensions.new(extension_create_params)

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

  def extension_create_params
    params.require(:extension).permit(:name)
  end

  def extension_update_params
    settings = Weby.extensions[@extension.name.to_sym].settings.dup
    settings << settings.select{|s| s.to_s.ends_with?('_') }.map{|s| [s, []] }.to_h

    params.require(:extension).permit(settings)
  end
end

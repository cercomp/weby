module Acadufg::Admin
  class SettingsController < Acadufg::ApplicationController
    
    def edit
      @setting = Acadufg::Setting.find(params[:id])
    end
  
    def create
      @setting = Acadufg::Setting.new(params[:setting])
      redirect_to(root_path, flash: {success: t('successfully_created')})
    end
  
    def update
      @setting = Acadufg::Setting.find(params[:id])
      redirect_to(root_path.join("admin"), flash: {success: t('successfully_updated')})
    end
  
    def destroy
      @setting = Acadufg::Setting.find(params[:id])
      @setting.destroy
    end
  end
end

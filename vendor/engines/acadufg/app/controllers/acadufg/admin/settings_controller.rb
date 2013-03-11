module Acadufg::Admin
  class SettingsController < Acadufg::ApplicationController
    before_filter :require_user
    before_filter :check_authorization
    
    respond_to :html, :js

    def show
      @setting = Acadufg::Setting.find(:first, :conditions => ["site_id = ?", current_site])
      @setting = @setting || Acadufg::Setting.new
    end
    
    def create
      @setting = Acadufg::Setting.new(params[:setting])
      if @setting.save
        redirect_to(admin_path, flash: {success: t('successfully_created')})
      else
        render :show
      end
    end
  
    def update
      @setting = Acadufg::Setting.find(:first, :conditions => ["site_id = ?", current_site])
      if @setting.update_attributes(params[:setting])
        redirect_to(admin_path, flash: {success: t('successfully_updated')})
      else
        render :show
      end
    end
  end
end

module Acadufg::Admin
  class SettingsController < Acadufg::ApplicationController
    before_action :require_user
    before_action :check_authorization

    respond_to :html, :js

    def show
      make_request 'uri_programas'
      @programas = ActiveSupport::JSON.decode(@response_text).map{|programa| [programa['nmPrograma'], programa['id']] }

      @setting = Acadufg::Setting.find_by(site_id: current_site)
      @setting ||= Acadufg::Setting.create site_id: current_site.id
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
      @setting = Acadufg::Setting.find_by(site_id: current_site)
      if @setting.update(params[:setting])
        redirect_to(admin_path, flash: {success: t('successfully_updated')})
      else
        render :show
      end
    end
  end
end

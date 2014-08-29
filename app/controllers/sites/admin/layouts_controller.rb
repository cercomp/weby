# encoding: utf-8

class Sites::Admin::LayoutsController < ApplicationController
  respond_to :html

  before_action :require_user
  before_action :is_admin, only: :is_admin

  def update_settings
    if current_site.update(site_params)
      flash[:success] = "Configurações atualizadas com sucesso."
    end

    respond_with current_site, location: settings_site_admin_layouts_path
  end

  private

  def site_params
    params.require(:site).permit(:head_html)
  end
end

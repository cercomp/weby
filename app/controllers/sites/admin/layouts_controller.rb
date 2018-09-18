class Sites::Admin::LayoutsController < ApplicationController
  respond_to :html

  before_action :require_user
  before_action :global_local_admin, only: :update_settings

  def update_settings
    if current_site.update(site_params)
      flash[:success] = t("successfully_updated")
      record_activity('layout_settings_updated', current_site)
    end

    respond_with current_site, location: settings_site_admin_layouts_path
  end

  private

  def site_params
    params.require(:site).permit(:head_html)
  end
end

class Admin::SettingsController < ApplicationController
  before_filter :require_user
  before_filter :is_admin
  respond_to :html, :xml, :js

  helper_method :sort_column

  def index
    if request.put? #&& params[:role]
      errors = ""
      params[:settings].each do |attr|
        enabled = attr.delete :enabled
        setting = Setting.new_or_update(attr)
        enabled ? setting.save : setting.destroy
        errors << setting.errors.full_messages.join(',')
      end
      errors.present? ? flash[:error] = errors : flash[:success] = t("successfully_updated")
      Weby::Settings.load_settings
    end

    @settings = Weby::Settings.all
  end

end

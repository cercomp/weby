class Admin::SettingsController < ApplicationController
  before_action :require_user
  before_action :is_admin
  respond_to :html, :xml, :js

  helper_method :sort_column

  def index
    if request.put?
      errors = ''
      settings_params[:settings].each do |attr|
        enabled = attr.delete :enabled
        setting = Setting.new_or_update(attr)
        enabled ? setting.save : setting.destroy
        errors << setting.errors.full_messages.join(',')
      end
      errors.present? ? flash[:error] = errors : flash[:success] = t('successfully_updated')
      Weby::Settings.clear
    end

    @settings = Weby::Settings.all
  end

  private

  def settings_params
    params.permit(settings: [:id, :name, :value, :enabled])
  end
end

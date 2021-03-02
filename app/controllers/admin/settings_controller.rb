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
    @execs = Dir.glob(File.join('db', 'data_migrations', '*')).select do |f|
      File.file?(f) && f.to_s.match(/\.rb$/)
    end.map do |f|
      f.match(/(\w+)\.rb$/)[1]
    end
    @settings = Weby::Settings.all
  end

  def exec
    if params[:file].present?
      begin
        res = Weby::run_data_migration params[:file]
        flash[:notice] = t('.result', result: res)
      rescue Exception => e
        flash[:error] = [e.message, e.backtrace.first(5)].flatten.join('<br>')
      end
    else
      flash[:error] = t('.select_file')
    end
    redirect_to admin_settings_path
  end

  private

  def settings_params
    params.permit(settings: [:id, :name, :value, :enabled, :group])
  end
end

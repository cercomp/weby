class SettingsController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml

  def index
    if request.put?
      RolesSetting.delete_all()
      unless params[:group_osses].nil?
        params[:group_osses].each do |set, role|
          Setting.find(set).update_attributes(role)
        end
      end

      Setting.update_all("value = '#{params[:group_phone]}'", "settings.group = 'phone'")
      Setting.update_all("value = '#{params[:group_email]}'", "settings.group = 'email'")

      flash[:notice] = t:us, :param => t('setting')
    end

    @settings = Setting.find(:all)
    @roles    = Role.find(:all, :order => "id")

     respond_with(@settings)
  end

  def show
    @setting = Setting.find(params[:id])
    respond_with(@setting)
  end

  def edit
    @setting = Setting.find(params[:id])
  end

  def update
    @setting = Setting.find(params[:id])
    @setting.update_attributes(params[:setting])
    respond_with(@setting)
  end
end

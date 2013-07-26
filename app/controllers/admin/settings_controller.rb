class Admin::SettingsController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization
  respond_to :html, :xml, :js

  helper_method :sort_column

  def index
    @settings = Setting.order(sort_column + " " + sort_direction).
      page(params[:page]).per(params[:per])
  end

  def new
    @setting = Setting.new
  end

  def edit
    @setting = Setting.find(params[:id])
  end

  def create
    @setting = Setting.new(params[:setting])

    if @setting.save
      redirect_to(admin_settings_path, flash: {success: t("successfully_created")})
    else
      render :action => "new"
    end
  end

  def update
    @setting = Setting.find(params[:id])

    if @setting.update_attributes(params[:setting])
      redirect_to(admin_settings_path, flash: {success: t("successfully_updated")})
    else
      render :action => "edit"
    end
  end

  def destroy
    @setting = Setting.find(params[:id])
    @setting.destroy

    redirect_to(admin_settings_url)
  end

  private
  def sort_column
    Setting.column_names.include?(params[:sort]) ? params[:sort] : 'name'
  end
end

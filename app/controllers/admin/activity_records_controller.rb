class Admin::ActivityRecordsController < ApplicationController
  before_action :require_user
  before_action :is_admin
  respond_to :html, :js

  def index
    @activity_records = ActivityRecord.user_or_action_like(params[:search]).
                preload(:loggeable).
                includes(:user, :site).
                order('activity_records.created_at DESC')

    if params[:site_id].present?
      @activity_records = @activity_records.where(site_id: params[:site_id])
    end

    @activity_records = @activity_records.page(params[:page]).per(params[:per_page] || per_page_default)
  end

  def show
    @activity_record = ActivityRecord.find(params[:id])
  end

  def destroy
    @activity_record = ActivityRecord.find(params[:id])
    @activity_record.destroy
    flash[:success] = t('destroyed_record')

    redirect_to admin_activity_records_path
  end
end

class Admin::ActivityRecordsController < ApplicationController
  before_filter :require_user 
  before_filter :is_admin
  respond_to :html, :js

  def index
    @activity = ActivityRecord.user_or_action_like(params[:search], params[:site_id]).
                order("activity_records.created_at DESC").
                page(params[:page]).
                per(params[:per_page] || per_page_default)
  end

  def show
    @activity = ActivityRecord.find(params[:id])
  end

  def new
    @activity = ActivityRecord.new
  end

  def create
    @activity = ActivityRecord.new(params[:activity_record])
  end

  def destroy
    @activity = ActivityRecord.find(params[:id])
    @activity.destroy
    flash[:success] = t("destroyed_record")

    redirect_to :back
  end
end

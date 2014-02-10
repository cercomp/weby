class Sites::Admin::ActivityRecordsController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization
  before_filter :is_admin, only: [:show]

  def index
    @activity_records = ActivityRecord.user_or_action_like(params[:search], current_site.id).
                order("activity_records.created_at DESC").
                page(params[:page]).
                per(params[:per_page] || per_page_default)
  end

  def show
    @activity_record = ActivityRecord.find(params[:id])
  end
end

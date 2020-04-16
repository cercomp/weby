class Sites::Admin::ActivityRecordsController < ApplicationController
  before_action :require_user
  before_action :check_authorization
  before_action :is_admin, only: [:show]

  def index
    @activity_records = current_site.activity_records.
                preload(:loggeable).
                includes(:user, :site).
                user_or_action_like(params[:search]).
                order('activity_records.created_at DESC').
                page(params[:page]).
                per(params[:per_page] || per_page_default)
  end

  def show
    @activity_record = current_site.activity_records.find(params[:id])
  end
end

class Sites::Admin::ActivityRecordsController < ApplicationController
  before_filter :require_user

  def index
    @activity = ActivityRecord.user_or_action_like(params[:search], current_site.id).
                order("created_at DESC")
  end
end

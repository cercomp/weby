class Admin::ActivityRecordsController < ApplicationController
  respond_to :html, :js

  def index
    @activity = ActivityRecord.all
  end

  def show
  end

  def new
    @activity = ActivityRecord.new
  end

  def create
    @activity = ActivityRecord.new(params[:activity_record])
  end

  def edit
  end

  def destroy
  end
  
  def update
  end
end

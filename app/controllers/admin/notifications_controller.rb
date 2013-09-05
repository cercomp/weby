class Admin::NotificationsController < ApplicationController
  before_filter :require_user
  before_filter :is_admin
  respond_to :html, :js

  def index
    @notifications = Notification.title_or_body_like(params[:search]).
                     order("created_at DESC").
                     page(params[:page]).
                     per(params[:per_page] || per_page_default)
  end

  def new
    @notification = Notification.new 
  end

  def edit
    @notification = Notification.find(params[:id])
    respond_with(:admin, @notification)
  end

  def create
    @notification = Notification.new(params[:notification])
    @notification.user_id = current_user.id
    if @notification.save
      flash[:success] = t("create_notification_successful")
      redirect_to admin_notification_path @notification
    else
      flash[:error] = t("problem_create_notification")
      render :action => :new
    end
    User.no_admin.each do |user|
      user.append_unread_notification @notification
    end
  end

  def update
    @notification = Notification.find(params[:id])

    if @notification.update_attributes(params[:notification])
      redirect_to admin_notification_path @notification
      flash[:success] = t("update_notification_successful")
    else
      flash[:error] = t("problem_update_notification")
      render action: "index"
    end
  end

  def show
    @notification = Notification.find(params[:id])
  end

  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy
    flash[:success] = t("destroyed_param", :param => @notification.title)
    User.no_admin.each do |user|
      user.remove_unread_notification @notification
    end
  rescue ActiveRecord::DeleteRestrictionError
    flash[:warning] = t("problem_destroy_notification")
  ensure
    redirect_to admin_notifications_path
  end
end

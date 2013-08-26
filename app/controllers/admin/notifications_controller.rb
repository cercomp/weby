class Admin::NotificationsController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization
  before_filter :is_admin
  respond_to :html, :xml

  def index
    @notifications = (Notification.title_or_body_like(params[:search])).sort_by(&:created_at).reverse

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @notification }
    end
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
    User.all.each do |user|
      unread = user.unread_notifications || ""
      unread += "#{@notification.id},"
      user.update_attribute(:unread_notifications, unread) unless user.id == 1
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
  rescue ActiveRecord::DeleteRestrictionError
    flash[:warning] = t("problem_destroy_notification")
  ensure
    redirect_to admin_notifications_path
  end
end

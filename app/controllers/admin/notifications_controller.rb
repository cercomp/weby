class Admin::NotificationsController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization, :except => [:show]
  before_filter :is_admin, except: [:edit]
  respond_to :html, :xml

  def index
    @notifications = (Notification.all).sort_by(&:created_at).reverse

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
      redirect_to admin_notifications_path
    else
      flash[:error] = t("problem_create_notification")
      render :action => :new
    end
  end

  def update
    @notification = Notification.find(params[:id])

    if @notification.update_attributes(params[:notification])
      redirect_to admin_notifications_path
      flash[:success] = t("update_notification_successful")
    else
      flash[:error] = t("problem_update_notification")
      render action: "index"
    end
  end

  def show
    @notification = Notification.find(params[:id])
    #respond_with(:admin, @notification)
  end

  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy
    flash[:success] = t("destroyed_param", :param => @notification.title)
  rescue ActiveRecord::DeleteRestrictionError
    flash[:warning] = t("user_cant_be_deleted")
  ensure
    redirect_to admin_notification_path
  end
end

class Admin::NotificationsController < Admin::BaseController
  before_action :set_notification, only: [:edit, :update, :show, :destroy]

  respond_to :html, :js

  def index
    @notifications = Notification.title_or_body_like(params[:search])
      .order('created_at DESC')
      .page(params[:page])
      .per(params[:per_page] || per_page_default)
  end

  def new
    @notification = Notification.new
  end

  def create
    @notification = Notification.new(notification_params)
    @notification.user_id = current_user.id

    if @notification.save
      record_activity('created_notification', @notification)

      User.no_admin.each { |user| user.append_unread_notification @notification }

      redirect_to(admin_notification_path(@notification), notice: t('create_notification_successful'))
    else
      flash[:alert] = t('problem_create_notification')

      render :new
    end
  end

  def edit
  end

  def update
    if @notification.update(notification_params)
      record_activity('updated_notification', @notification)

      redirect_to(admin_notification_path(@notification), notice: t('update_notification_successful'))
    else
      flash[:alert] = t('problem_update_notification')

      render :edit
    end
  end

  def show
  end

  def destroy
    @notification.destroy

    record_activity('destroyed_notification', @notification)

    User.no_admin.each { |user| user.remove_unread_notification @notification }

    redirect_to(admin_notifications_path, notice: t('destroyed_param', param: @notification.title))
  end

  private

  def set_notification
    resource
  end

  def notification_params
    params.require(:notification).permit(:title, :body)
  end
end

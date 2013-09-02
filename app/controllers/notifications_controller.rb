class NotificationsController < ApplicationController
  before_filter :require_user
  respond_to :html, :js
  layout 'weby_pages'

  def index
    @notifications = (Notification.title_or_body_like(params[:search]).
                     page(params[:page]).
                     per((params[:per_page] || per_page_default))).
                     order("created_at DESC")
  end

  def show
    @notification = Notification.find(params[:id])
    set_as_read @notification
  end

  def mark_as_read
    set_as_read
    redirect_to notifications_path
  end

  private
  def set_as_read notification=nil
    user = User.find(current_user.id)
    user.remove_unread_notification notification
  end
end

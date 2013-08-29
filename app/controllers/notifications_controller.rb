class NotificationsController < ApplicationController
  before_filter :require_user
  respond_to :html, :json
  layout 'weby_pages'

  def index
    #TODO Pagination!
    @notifications = (Notification.title_or_body_like(params[:search])).sort_by(&:created_at).reverse

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @notifications }
    end
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

class Sites::Admin::NotificationsController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization
  respond_to :html, :xml

  def index
    @notifications = (Notification.title_or_body_like(params[:search])).sort_by(&:created_at).reverse

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @notification }
    end
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def show
    @notification = Notification.find(params[:id])
    set_as_read(@notification.id)
  end

  def destroy
  end
  
  def mark_as_read
    set_as_read(params[:text])
    redirect_to site_admin_notifications_path
  end

  private
  def set_as_read(text)
    user = User.find(current_user.id)
    unread = user.unread_notifications

    case text
    when "all"
      user.update_attribute(:unread_notifications, "$")
    else
      unread = unread.gsub "#{text}$", ""
      user.update_attribute(:unread_notifications, unread)
    end
  end
end

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
  end

  def destroy
  end
end

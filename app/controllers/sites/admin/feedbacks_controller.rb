class Sites::Admin::FeedbacksController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization
  before_filter :get_groups, :only => [:new, :edit, :create, :update]
  respond_to :html, :xml, :js

  def index
    @feedbacks = Feedback.where(:site_id => @site.id).order('id desc')
  end

  def show
    @feedback = Feedback.find(params[:id])
  end

  def edit
    @feedback = Feedback.find(params[:id])
  end

  def update
    @feedback = Feedback.find(params[:id])

    if @feedback.update_attributes(params[:feedback])
      redirect_to(site_admin_feedback_path(@feedback),
                  flash: {success: t("successfully_updated")})
    else
      render :action => "edit"
    end
  end

  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy

    redirect_to(site_admin_feedbacks_path)
  end
  
  private
  def get_groups
    @groups = Group.where(:site_id => @site.id)
  end
end

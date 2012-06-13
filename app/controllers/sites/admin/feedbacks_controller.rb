class Sites::Admin::FeedbacksController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization
  before_filter :get_groups, :only => [:new, :edit, :create, :update]
  respond_to :html, :xml, :js

  def index
    @feedbacks = Feedback.where(:site_id => @site.id).order('id desc')
    #Group.find(:all, :select => 'name')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @feedbacks }
    end
  end

  def show
    @feedback = Feedback.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feedback }
    end
  end

  def edit
    @feedback = Feedback.find(params[:id])
  end

  def update
    @feedback = Feedback.find(params[:id])

    respond_to do |format|
      if @feedback.update_attributes(params[:feedback])
        format.html { redirect_to(site_admin_feedback_path(@feedback),
                      flash: {success: t("successfully_updated")}) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feedback.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy

    respond_to do |format|
      format.html { redirect_to(site_admin_feedbacks_path) }
      format.xml  { head :ok }
    end
  end
  
  private
  def get_groups
    @groups = Group.where(:site_id => @site.id)
  end
end

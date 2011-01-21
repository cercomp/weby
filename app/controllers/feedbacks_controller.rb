class FeedbacksController < ApplicationController
  layout :choose_layout

  before_filter :get_groups, :only => [:new, :edit, :create, :update]

  respond_to :html, :xml, :js

  def get_groups
    @groups = Group.where(:site_id => @site.id)
  end

  def index
    @feedbacks = Feedback.where(:site_id => @site.id)

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

  def new
    @feedback = Feedback.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feedback }
    end
  end

  def edit
    @feedback = Feedback.find(params[:id])
  end

  def create
    @feedback = Feedback.new(params[:feedback])

    respond_to do |format|
      if @feedback.save
        FeedbackMailer.send_feedback(@feedback).deliver
        format.html { redirect_to(site_feedback_path(@site.id, @feedback), :notice => t("successfully_created")) }
        format.xml  { render :xml => @feedback, :status => :created, :location => @feedback }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feedback.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @feedback = Feedback.find(params[:id])

    respond_to do |format|
      if @feedback.update_attributes(params[:feedback])
        format.html { redirect_to(site_feedback_url,
                      :notice => t("successfully_updated")) }
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
      format.html { redirect_to(site_feedbacks_url) }
      format.xml  { head :ok }
    end
  end
end

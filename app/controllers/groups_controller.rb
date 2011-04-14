class GroupsController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization
  respond_to :html, :xml, :js

  helper_method :sort_column

  def index
    @groups = Group.order(sort_column + ' ' + sort_direction).
      page(params[:page]).per(params[:per_page])

    unless @groups
      flash.now[:warning] = (t"none_param", :param => t("group.one"))
    end

    respond_with do |format|
      format.js  
      format.xml  { render :xml => @banners }
      format.html
    end
  end

  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  def new
    @group = Group.new
    @users = User.find(:all)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  def edit
    @group = Group.find(params[:id])
    @users = User.find(:all)
  end

  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        format.html {
          redirect_to({:site_id => @group.site.name, :controller => 'groups'},
                      :notice => t('successfully_created')) }
                      format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { respond_with(@site, @group) }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @group = Group.find(params[:id])
    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html {
          redirect_to({:site_id => @group.site.name, :controller => 'groups', :action => 'index'},
                      :notice => t('successfully_updated')) }
                      format.xml  { head :ok }
      else
        format.html { redirect_to :back }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(site_groups_url) }
      format.xml  { head :ok }
    end
  end

  private
  def sort_column
    Group.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end
end

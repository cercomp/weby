class GroupsController < ApplicationController
  layout :choose_layout

  respond_to :html, :xml, :js
  def index
    @groups = Group.paginate :page => params[:page], :per_page => 10

    respond_with do |format|
      format.js { 
        render :update do |site|
          site.call "$('#list').html", render(:partial => 'list')
        end
      }
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
          redirect_to({:site_id => @group.site.name, :controller => 'groups', :action => 'index'},
                      :notice => t('successfully_created')) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :site_id => @site.id, :controller => 'groups', :action => 'new' }
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

end

class GroupsController < ApplicationController
  layout :choose_layout
  # GET /groups
  # GET /groups.xml
  def index
    @groups = Group.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @group = Group.new
    @users = @group.users_off_groups

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
    @users = @group.users_off_groups
  end

  # POST /groups
  # POST /groups.xml
  def create
    @group = Group.new(params[:group])
    @users = params[:users_ids] || []

    respond_to do |format|
      if @group.save
        # Cadastra usuarios no grupo
        unless @users.empty?
          @users.each do |u|
            @group.users << User.find(u)
          end
        end

        format.html {
          redirect_to(
                      {:site_id => @group.site.id, :controller => 'groups', :action => 'index'},
                      :notice => t('successfully_created')
          )
        }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :site_id => @site.id, :controller => 'groups', :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html {
         redirect_to(
                      {:site_id => @group.site_id, :controller => 'groups', :action => 'index'},
                      :notice => t('successfully_updated'))
          )
	}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(site_groups_url) }
      format.xml  { head :ok }
    end
  end

end

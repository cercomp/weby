class RepositoriesController < ApplicationController
  layout :choose_layout, :except => [:show]
 
  respond_to :html, :xml, :js

  def manage
    @repositories = @site.repositories.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
    respond_with(@repositories)
  end

  def index
    @repositories = @site.repositories.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 5
    respond_with(@repositories)
  end

  def show
    @repository = Repository.find(params[:id])
    respond_with(@repository)
  end

  def new
    @repository = Repository.new
    respond_with(@repository)
  end

  def edit
    @repository = Repository.find(params[:id])
  end

  def create
    @repository = Repository.new(params[:repository])

    respond_to do |format|
      if @repository.save
        format.html { redirect_to(:site_id => @repository.site.name, :controller => "repositories", :action => 'show', :id => @repository.id) }
        flash[:notice] = t("successfully_created") 
        format.xml  { render :xml => @repository, :status => :created, :location => @repository }
      else
        format.html { redirect_to :back }
        flash[:error] = @repository.errors.full_messages 
        format.xml  { render :xml => @repository.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @repository = Repository.find(params[:id])

    respond_to do |format|
        if @repository.update_attributes(params[:repository]) 
        format.html { redirect_to(:site_id => @repository.site.name, :controller => 'repositories', :action => 'show', :id => @repository.id) }
        format.xml  { head :ok }
        flash[:notice] = t("successfully_updated") 
      else
        format.html { redirect_to :back }
        format.xml  { render :xml => @repository.errors, :status => :unprocessable_entity }
        flash[:error] = @repository.errors.full_messages
      end
    end
  end

  def destroy
    @repository = Repository.find(params[:id])
    @repository.destroy

    respond_to do |format|
      format.html { redirect_to({:site_id => @repository.site.name, :controller => 'repositories', }) }
      format.xml  { head :ok }
    end
  end
end

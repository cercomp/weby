class RepositoriesController < ApplicationController
  layout :choose_layout, :except => [:show]
 
  respond_to :js

  def manage
    @repositories = @site.repositories.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
    respond_with(@repositories)
  end

  # GET /repositories
  # GET /repositories.xml
  def index
    @repositories = Repository.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @repositories }
    end
  end

  # GET /repositories/1
  # GET /repositories/1.xml
  def show
    @repository = Repository.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @repository }
    end
  end

  # GET /repositories/new
  # GET /repositories/new.xml
  def new
    @repository = Repository.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @repository }
    end
  end

  # GET /repositories/1/edit
  def edit
    @repository = Repository.find(params[:id])
  end

  # POST /repositories
  # POST /repositories.xml
  def create
    @repository = Repository.new(params[:repository])

    respond_to do |format|
      if @repository.save
        format.html { redirect_to(:site_id => @repository.site.name, :controller => "repositories", :action => 'show', :id => @repository.id) }
        flash[:notice] = t("successfully_created") 
        format.xml  { render :xml => @repository, :status => :created, :location => @repository }
      else
        format.html { redirect_to :back }
        flash[:error] = @repository.errors.full_messages # usar @repository.errors.any? na view para mostrar erros
        format.xml  { render :xml => @repository.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /repositories/1
  # PUT /repositories/1.xml
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

  # DELETE /repositories/1
  # DELETE /repositories/1.xml
  def destroy
    @repository = Repository.find(params[:id])
    @repository.destroy

    respond_to do |format|
      format.html { redirect_to({:site_id => @repository.site.name, :controller => 'repositories', }) }
      format.xml  { head :ok }
    end
  end
end

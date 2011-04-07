class RepositoriesController < ApplicationController
  layout :choose_layout, :except => [:show]
  before_filter :require_user
  before_filter :check_authorization

  helper_method :sort_column
 
  respond_to :html, :xml, :js
  def manage
    @repositories = @site.repositories.paginate :page => params[:page], :order => 'created_at DESC', :per_page => params[:per_page]
    respond_with(@repositories)
  end

  def index
    @repositories = @site.repositories.paginate :page => params[:page], :order => 'created_at DESC',
        :per_page => params[:per_page], :order => sort_column + ' ' + sort_direction

    respond_with do |format|
      format.js { 
        render :update do |page|
          page.call "$('#repo_list').html", render(:partial => 'repo_list')
        end
      }
      format.html
    end
  end

  def show
    @repository = Repository.find(params[:id])
    respond_with(@repository)
  end

  def new
    @repository = Repository.new

    respond_to do |format|
      format.js do 
        render :update do |page|
          page.call "$('#page').html", render(:partial => 'pages/newRepo')
        end
      end 
      format.html
    end
  end

  def edit
    @repository = Repository.find(params[:id])
  end

  def create
    @repository = Repository.new(params[:repository])
    respond_to do |format|
      if @repository.save
        format.html { 
          if params[:from] != 'other'
            redirect_to(:site_id => @repository.site.name, :controller => 'repositories', :action => 'show', :id => @repository.id) 
          else
            redirect_to :back
          end
         } 
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
      format.html { redirect_to({:site_id => @repository.site.name, :controller => 'repositories'}) }
      format.xml  { head :ok }
    end
  end

  private
  def sort_column
    Repository.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end
end

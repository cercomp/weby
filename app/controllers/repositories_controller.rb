class RepositoriesController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization
  before_filter :load_images, :only => [:new, :edit]

  helper_method :sort_column
 
  respond_to :html, :xml, :js
  def manage
    @repositories = @site.repositories.order('created_at DESC').page(params[:page]).per(params[:per_page])
    respond_with(@repositories)
  end

  def index
    @repositories = @site.repositories.description_or_file_and_content_file(params[:search], '').order(sort_column + ' ' + sort_direction).page(params[:page]).per(params[:per_page])
    unless @repositories
      flash.now[:warning] = (t"none_param", :param => t("archive.one")) 
    end
  end

  def show
    @repository = Repository.find(params[:id])
    respond_with(@repository)
  end

  def new
    @repository = Repository.new
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

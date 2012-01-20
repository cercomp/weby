class RepositoriesController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

  helper_method :sort_column

  respond_to :html, :xml, :js, :json
  def index
    params[:mime_type].try(:delete, "")

    @repositories = @site.repositories.
      description_or_filename(params[:search]).
      order(sort_column + ' ' + sort_direction).
      page(params[:page]).per(params[:per_page])

    @repositories = @repositories.content_file(params[:mime_type]) if params[:mime_type]

    request_type = request.env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest" ? 'js' : 'html'

    if params[:template] 
      render :template => "repositories/#{params[:template]}.#{request_type}.erb"
    end

    unless @repositories
      flash.now[:warning] = (t"none_param", :param => t("archive.one")) 
    end
    respond_with(@repositories) do |format|
      format.json do
        render json: {
          current_page: @repositories.current_page,
          num_pages: @repositories.num_pages,
          repositories: @repositories
        }
      end
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
    respond_with(@repository) do |format|
      if @repository.save
        format.html { 
          if params[:from] != 'other'
            redirect_to(:site_id => @repository.site.name, :controller => 'repositories', :action => 'show', :id => @repository.id) 
          else
            redirect_to :back
          end
        } 
        format.json do
          render json: { repositories: @repository, message: t("successfully_created") },
            content_type: check_accept_json
        end
      else
        format.html { redirect_to :back }
        format.json do
          #render :json => { result: @repository.errors.full_messages },
          #  :content_type => 'text/html', status: 500
          render json: { error: @repository.errors.full_messages }, content_type: check_accept_json#, status: 500
        end
        #flash[:error] = @repository.errors.full_messages 
      end
    end
  end

  def update
    @repository = Repository.find(params[:id])

    respond_to do |format|
      if @repository.update_attributes(params[:repository]) 
        format.html { redirect_to(:site_id => @repository.site.name, :controller => 'repositories', :action => 'show', :id => @repository.id) }
        flash[:notice] = t("successfully_updated") 
      else
        format.html { redirect_to :back }
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

  def check_accept_json
    request.env['HTTP_ACCEPT'].include?('application/json') ?
      'application/json' :
      'text/plain'
  end
end

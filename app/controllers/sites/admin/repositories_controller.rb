class Sites::Admin::RepositoriesController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization
  
  helper_method :sort_column

  respond_to :html, :xml, :js, :json
  def index
    params[:mime_type] ||= params[:empty_filter]
    params[:mime_type].try(:delete, "")
    params[:direction] ||= 'desc'

    @repositories = @site.repositories.
      description_or_filename(params[:search]).
      order(sort_column + ' ' + sort_direction).
      page(params[:page]).per(per_page)

    @repositories = @repositories.content_file(params[:mime_type]) if params[:mime_type]

    respond_with(:site_admin, @repositories) do |format|
      format.json do
        render json: {
          current_page: @repositories.current_page,
          num_pages: @repositories.num_pages,
          repositories: @repositories
        }
      end
      if params[:template] 
        format.html { render "#{params[:template]}" }
        format.js { render "#{params[:template]}" }
      end
    end
  end

  def show
    @repository = Repository.find(params[:id])
    respond_with(:site_admin, @repository)
  end

  def new
    @repository = Repository.new
  end

  def edit
    @repository = Repository.find(params[:id])
  end

  def create
    @repository = Repository.new(params[:repository])
    respond_with(:site_admin, @repository) do |format|
      if @repository.save
        format.html do
          if params[:from] != 'other'
            redirect_to([:site, :admin, @repository])
          else
            redirect_to :back
          end
        end
        format.json do
          render json: { :repositories => @repository,
                         :message => t("successfully_created"),
                         :url => site_admin_repository_path(@repository) },
            content_type: check_accept_json
        end
      else
        format.html { render action: :new }
        format.json do
          render json: { :errors => @repository.errors.full_messages }, status: 412,
            content_type: check_accept_json
        end
      end
    end
  end

  def update
    @repository = Repository.find(params[:id])

    if @repository.update_attributes(params[:repository]) 
      flash[:success] = t("successfully_updated") 
      redirect_to [:site, :admin, @repository]
    else
      render action: :edit
    end
  end

  def destroy
    @repository = Repository.find(params[:id])
    @repository.destroy

    redirect_to site_admin_repositories_url
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

  def per_page
    if params[:template]
      if params[:template]=='tinymce_link'
        return 12
      elsif params[:template]=='tinymce'
        return 18
      end
    end
    params[:format] == 'json' ? 50 : params[:per_page] || per_page_default
  end
end

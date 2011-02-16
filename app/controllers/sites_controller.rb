class SitesController < ApplicationController
  layout :choose_layout

  before_filter :require_user, :only => [:new, :create, :edit, :update, :destroy, :select_top_banner]
  before_filter :check_authorization, :except => [:show, :index]

  respond_to :html, :xml

  def index
    @sites = Site.paginate :page => params[:page], :per_page => 10

    respond_with do |format|
      format.js { 
        render :update do |site|
          site.call "$('#list').html", render(:partial => 'list')
        end
      }
      format.html
    end
  end

  def show
    @site = Site.find_by_name(params[:id])
    respond_with(@site)
  end

  def new
    @site = Site.new
    respond_with(@site)
  end

  def edit
    @repositories = Repository.search(params[:search], params[:page],["archive_content_type LIKE ?","image%"])
#    @repositories = Repository.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 1 
   	@site = Site.find_by_name(params[:id])
  end

  def create
    @site = Site.new(params[:site])
    @site.save
    respond_with(@site)
  end

  def update
    @site = Site.find_by_name(params[:id])
		if @site.update_attributes(params[:site])
      flash[:notice] = t"successfully_updated"
    end
    redirect_to edit_site_admin_path(@site, @site)
  end

  def destroy
    @site = Site.find_by_name(params[:id])
    @site.destroy
    respond_with(@site)
  end

	def select_top_banner
		@site = Site.find_by_name(params[:id])
		@reposiroties = Repository.all
		respond_with(@repositories)
	end

end

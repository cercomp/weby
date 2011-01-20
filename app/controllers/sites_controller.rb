class SitesController < ApplicationController
  layout :choose_layout

  before_filter :check_authorization, :except => [:show, :index]
  
  respond_to :html, :xml

  def index
    @sites = Site.all
    respond_with(@sites)
  end

  def show
    @site = Site.find_by_name(params[:id])
    respond_with(@site)
  end

  def new
    @site = Site.new
#    respond_with(@site)
  end

  def edit
    @site = Site.find_by_name(params[:id])
  end

  def create
    @site = Site.new(params[:site])
    @site.save
    respond_with(@site)
  end

  def update
    @site = Site.find_by_name(params[:id])
    @site.update_attributes(params[:site])
    respond_with(@site)
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

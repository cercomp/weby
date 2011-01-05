class PagesController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml

  def index 
    @pages = Object.const_get(params[:type]).all if params[:type]
    respond_with(@pages)
  end

  def show
    #@page = Page.find(params[:id])
    @page = Object.const_get(params[:type]).find(params[:id]) if params[:type]
    respond_with(@page)
  end

  def new
    @page = Object.const_get(params[:type]).new
    @page.sites_pages.build
    respond_with(@page)
  end

  def edit
    @page = Page.find(params[:id])
  end

  def create
    @page = Object.const_get(params[:type]).new(params[params[:type].downcase.to_s])
    @page.save
    respond_with(@page, :location => site_pages_path(:type => params[:type]))
  end

  def update
    #@page = Object.const_get(params[:type]).find(params[:id])
    @page = Page.find(params[:id])
    @page.update_attributes(params[@page.class.name.underscore])
    respond_with(@page, :location => site_pages_path(:type => params[:type]))
  end

  def destroy
    @page = Page.find(params[:id])
    # deleta todas as relacoes da pagina com os sites
    SitesPage.find(@page.sites_pages).each{ |p| p.destroy }
    @page.destroy
    redirect_to(:back)
  end
end

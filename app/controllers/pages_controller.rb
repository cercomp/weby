class PagesController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

#  uses_tiny_mce :options => {
#    :editor_selector => "mceEditor",
#    :theme => "advanced",
#    :language => "pt",
#    :browsers => %w{msie gecko safari},
#    :cleanup_on_startup => true,
#    :convert_fonts_to_spans => true,
#    :relative_urls => false,
#    :theme_advanced_resizing => true, 
#    :theme_advanced_toolbar_location => "top",  
#    :theme_advanced_statusbar_location => "bottom", 
#    :editor_deselector => "mceNoEditor",
#    :theme_advanced_resize_horizontal => false,  
#    :theme_advanced_buttons1 => %w{bold italic underline separator bullist numlist separator link unlink image separator help separator pasteword},
#    :theme_advanced_buttons2 => [],
#    :theme_advanced_buttons3 => [],
#    :plugin_preview_pageurl => @site.to_s,
#    :plugins => %w{inlinepopups safari curblyadvimage paste}
#  }, :only => [:new, :edit]

  respond_to :html, :xml, :js

  def index 
    params[:type] ||= 'News'
 
    @pages = Object.const_get(params[:type]).all
    respond_with(@pages)
  end

  def show
    #@page = Page.find(params[:id])
    @page = Object.const_get(params[:type]).find(params[:id]) if params[:type]
    respond_with(@page)
  end

  def new
    params[:type] ||= 'News'

    @page = Object.const_get(params[:type].capitalize).new
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

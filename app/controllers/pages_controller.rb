class PagesController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml, :js
  def index 
    params[:type] ||= 'News'
 
    @pages = @site.pages.all
    respond_with(@pages)
  end

  def show
    @page = Page.find(params[:id])
    params[:type] ||= @page.type
    respond_with(@page)
  end

  def new
    params[:type] ||= 'News'

    # Objeto para repository_id (relacionamento um-para-um)
    @repositories = Repository.where(["site_id = ? AND archive_content_type LIKE ?", @site.id, "image%"]).paginate :page => params[:page], :order => 'created_at DESC', :per_page => 4 
    # Objeto para pages_repositories (relacionamento muitos-para-muitos)
    @repo_files = @site.repositories.paginate :page => params[:page_files], :order => 'created_at DESC', :per_page => 5

    @page = Page.new
    @page.sites_pages.build
    @page.pages_repositories.build
    respond_with do |format|
      format.js { 
        render :update do |page|
          page.call "$('#repo_list').html", render(:partial => 'repo_list', :locals => { :f => SemanticFormBuilder.new(:page, @page, self, {}, proc{}) })
          page.call "$('#div_event').html", render(:partial => 'formEvent', :locals => { :f => SemanticFormBuilder.new(:page, @page, self, {}, proc{}) })
        end
      }
      format.html
    end
  end

  def edit
    # Objeto para repository_id (relacionamento um-para-um)
    @repositories = Repository.where(["site_id = ? AND archive_content_type LIKE ?", @site.id, "image%"]).paginate :page => params[:page], :order => 'created_at DESC', :per_page => 4 
    # Objeto para pages_repositories (relacionamento muitos-para-muitos)
    @repo_files = @site.repositories.paginate :page => params[:page_files], :order => 'created_at DESC', :per_page => 5
    @page = Page.find(params[:id])
    # Automaticamente define o tipo, se não for passado como parâmetro
    params[:type] ||= @page.type

    respond_with do |format|
      format.js { 
        render :update do |page|
          if params[:page]
            page.call "$('#repo_list').html", render(:partial => 'repo_list', :locals => { :f => SemanticFormBuilder.new(@page.class.name.underscore.to_s, @page, self, {}, proc{}) })
          elsif params[:page_files]
            page.call "$('#files_list').html", render(:partial => 'files_list')
          end
        end
      }
      format.html
    end
  end

  def create
    params[:page][:type] ||= 'News'
    @page = Object.const_get(params[:page][:type]).new(params[:page])
    @page.save
    respond_with(@page, :location => site_pages_path(:type => params[:type]))
  end

  def update
    @page = Page.find(params[:id])
    # Se não houver nenhum checkbox marcado, remover todos.
    params[@page.class.name.underscore.to_s][:repository_ids] ||= []
    if @page.update_attributes(params[@page.class.name.underscore.to_s])
      flash[:notice] = t"successfully_updated"
    end
    #respond_with(@page, :location => site_pages_path(:type => params[:type]))
    redirect_to site_page_path(@site, @page)
  end

  def destroy
    @page = Page.find(params[:id])
    # deleta todas as relacoes da pagina com os sites
    SitesPage.find(@page.sites_pages).each{ |p| p.destroy }
    @page.destroy
    redirect_to(:back)
  end
end

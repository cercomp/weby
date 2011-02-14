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

    @page = Page.new
    @page.sites_pages.build
    @page.pages_repositories.build
    # Objeto para repository_id (relacionamento um-para-um)
    @repositories = Repository.where(["site_id = ? AND archive_content_type LIKE ?", @site.id, "image%"]).paginate :page => params[:page], :order => 'created_at DESC', :per_page => 4 
    # Objeto para pages_repositories (relacionamento muitos-para-muitos)
    ## Criando objeto com os arquivos que não estão relacionados com a página
    @page_files_unchecked = (@site.repositories - @page.repositories).paginate :page => params[:page_files], :order => 'created_at DESC', :per_page => 5

    respond_with do |format|
      format.js { 
        render :update do |page|
          if params[:page]
            page.call "$('#repo_list').html", render(:partial => 'repo_list', :locals => { :f => SemanticFormBuilder.new(:page, @page, self, {}, proc{}) })
          elsif params[:page_files]
            page.call "$('#files_list').append", render(:partial => 'files_list')
            page.call "$('#will_paginate').html", (will_paginate @page_files_unchecked, :param_name => 'page_files', :previous_label => t("will_paginate.previous"), :next_label => t("will_paginate.next"), :class => 'pagination ajax', :page_links => false, :renderer => Twitter, :twitter_label => t("more"))
          elsif params[:type]
            page.call "$('#div_event').html", render(:partial => 'formEvent', :locals => { :f => SemanticFormBuilder.new(:page, @page, self, {}, proc{}) })
          end
        end
      }
      format.html
    end
  end

  def edit
    # Objeto para pages_repositories (relacionamento muitos-para-muitos)
    @page = Page.find(params[:id])
    @page.pages_repositories.build
    # Automaticamente define o tipo, se não for passado como parâmetro
    params[:type] ||= @page.type

    # Objeto para repository_id (relacionamento um-para-um)
    @repositories = Repository.where(["site_id = ? AND archive_content_type LIKE ?", @site.id, "image%"]).paginate :page => params[:page], :order => 'created_at DESC', :per_page => 4 
    # Criando objeto com os arquivos que não estão relacionados com a página
    @page_files_unchecked = (@site.repositories - @page.repositories).paginate :page => params[:page_files], :order => 'created_at DESC', :per_page => 5

    respond_with do |format|
      format.js { 
        render :update do |page|
          if params[:page]
            page.call "$('#repo_list').html", render(:partial => 'repo_list', :locals => { :f => SemanticFormBuilder.new(@page.class.name.underscore.to_s, @page, self, {}, proc{}) })
          elsif params[:page_files]
            page.call "$('#files_list').append", render(:partial => 'files_list')
            page.call "$('#will_paginate').html", (will_paginate @page_files_unchecked, :param_name => 'page_files', :previous_label => t("will_paginate.previous"), :next_label => t("will_paginate.next"), :class => 'pagination ajax', :page_links => false, :renderer => Twitter, :twitter_label => t("more"))
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
    params[@page.type.downcase.to_s][:repository_ids] ||= [] 
    if @page.update_attributes(params[@page.type.downcase.to_s])
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

  def toggle_field
    @page = Page.find(params[:id])
    if params[:field] 
      if @page.update_attributes("#{params[:field]}" => (@page[params[:field]] == 0 or not @page[params[:field]] ? true : false))
        flash[:notice] = t"successfully_updated"
      else
        flash[:notice] = t"error_updating_object"
      end
    end
    redirect_back_or_default site_pages_path(@site)
  end
end

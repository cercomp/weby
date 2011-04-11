class PagesController < ApplicationController
  layout :choose_layout
  before_filter :require_user, :only => [:new, :edit, :update, :destroy, :sort, :toggle_field]
  before_filter :check_authorization, :except => [:view, :show]
  respond_to :html, :xml, :js
  before_filter :per_page, :only => [:index]

  def index 
    params[:type] ||= 'News'

    @tiny_mce = params[:tiny_mce] || false

    @pages = @site.pages.where("title like '%#{params[:search]}'").
    order(sort_column + " " + sort_direction).
      page(params[:page]).per(per_page)

    @pages.published if @tiny_mce

    if @pages
      respond_with do |format|
        format.js { 
          render :update do |site|
          site.call "$('#page_list').html", ( @tiny_mce ? render(:partial => 'list_popup') : render(:partial => 'list') )
          end
        }
        format.xml  { render :xml => @pages }
        format.html
      end
    else
      flash[:warning] = (t"none_param", :param => t("page.one"))
    end
  end

  def show
    @page = Page.find(params[:id])
    params[:type] ||= @page.type
    respond_with(@page)
  end

  def new
    params[:type] ||= 'News'

    @repository = Repository.new
    @page = Page.new
    @page.sites_pages.build
    @page.pages_repositories.build
    # Objeto para repository_id (relacionamento um-para-um)
    @repositories = Repository.where(["site_id = ? AND archive_content_type LIKE ?", @site.id, "image%"]).order('created_at DESC').page(params[:page]).per(4)
    # Objeto para pages_repositories (relacionamento muitos-para-muitos)
    ## Criando objeto com os arquivos que não estão relacionados com a página
    @page_files_unchecked = @site.repositories.order('created_at DESC').page(params[:page_files]).per(5)

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
    @repository = Repository.new
    # Objeto para pages_repositories (relacionamento muitos-para-muitos)
    @page = Page.find(params[:id])
    @page.pages_repositories.build
    # Automaticamente define o tipo, se não for passado como parâmetro
    params[:type] ||= @page.type

    # Objeto para repository_id (relacionamento um-para-um)
    @repositories = Repository.where(["site_id = ? AND archive_content_type LIKE ?", @site.id, "image%"]).order('created_at DESC').page(params[:page]).per(params[:per_page])
    # Criando objeto com os arquivos que não estão relacionados com a página
    @page_files_unchecked = @site.repositories.where("id NOT IN (#{@page.repository_ids.to_s.delete('[]')})").order('created_at DESC').page(1).per(params[:page_files].to_i*5)

    respond_with do |format|
      format.js { 
        render :update do |page|
        if params[:page]
          page.call "$('#repo_list').html", render(:partial => 'repo_list', :locals => { :f => SemanticFormBuilder.new(@page.class.name.underscore.to_s, @page, self, {}, proc{}) })
        elsif params[:page_files]
          page.call "$('#files_list').append", render(:partial => 'files_list')
          page.call "$('#will_paginate').html", render(:partial => 'will_paginate')
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

  def view
    @front_news = @site.pages.where(["front='true' AND publish='true' AND date_begin_at <= ? AND date_end_at > ?", Time.now, Time.now]) || ""

    @no_front_news = @site.pages.where(["front='false' AND publish='true' AND date_begin_at <= ? AND date_end_at > ?", Time.now, Time.now]).
      page(params[:page]).per(params[:per_page])

    respond_with do |format|
      format.js { 
        render :update do |page|
        page.call "$('#no_front_news').html", render(:partial => 'no_front_news', :locals => { :f => SemanticFormBuilder.new(@page.class.name.underscore.to_s, @page, self, {}, proc{}) })
        end
      }
      format.html
    end
  end

  def sort
    @pages = @site.pages.paginate :page => params[:paginate], :per_page => 10

    @front_news = @site.pages.where(["front='true' AND publish='true' AND date_begin_at <= ? AND date_end_at > ?", Time.now, Time.now])

    @no_front_news = @site.pages.where(["front='false' AND publish='true' AND date_begin_at <= ? AND date_end_at > ?", Time.now, Time.now]).paginate :page => params[:page], :per_page => 5

    params['page'] ||= []
    params['page'].each do |p|
      page = Page.find(p)
      page.position = (params['page'].index(p.to_s).to_i + 1)
      page.save
    end
    respond_with do |format|
      format.js { 
        render :update do |page|
        if params[:from] == 'view'
          page.call "$('#list').html", render(:partial => 'viewNews')
        else
          #page.call "$('#list').html", render(:partial => 'list')
          render :nothing => true
        end
        end
      }
    end
  end

  helper_method :sort_column
  private
  def sort_column
    Page.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def per_page
    unless params[:per_page]
     @tiny_mce ? 5 : per_page_array.first
    else
      params[:per_page]
    end
  end
end

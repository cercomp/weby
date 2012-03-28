class ComponentsController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml, :js
  def index
    @site_components = @site.site_components.order('position asc')
  end

  def show
    @site_component = @site.site_components.find(params[:id])
  end

  def new
    if (comp = params[:component])
      ## FIXME verifica se o componente existe
      @component = eval("#{comp.classify}Component").new # cria uma nova instância do componente selecionado
    else
      render :available_components
    end
  end

  def edit
    @site_component = @site.site_components.find(params[:id])
  end

  def create
    if (comp = params[:component])
      ## FIXME verifica se o componente existe
      # cria uma nova instância do componente selecionado
      @component = eval("#{comp.classify}Component").new(params[:site_component])
      @component.valid?
      #render :text => @component.errors.messages.to_s
      render :text => params.to_s
      return

      if @site_component.save
        render :text => 'funcionou'
        return
        # TODO colocar tradução na mensagem de sucesso
        redirect_to(site_site_components_url, :notice => 'Componente criado com sucesso.')
      else
        render :action => "new"
      end
    else
      render :available_components
    end
  end

  def update
    @site_component = @site.site_components.find(params[:id])

    if @site_component.update_attributes(params[:site_component])
      # TODO colocar tradução na mensagem de sucesso
      redirect_to(site_site_components_url, :notice => 'Componente atualizado com sucesso.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @site_component = SiteComponent.find(params[:id])
    @site_component.destroy

    redirect_to(site_site_components_url)
  end
  
  def sort
    @site_components = @site.site_components

    params['sort_sites_component'] ||= []
    params['sort_sites_component'].to_a.each do |p|
      site_component = SiteComponent.find(p)
      site_component.position = (params['sort_sites_component'].index(p) + 1)
      site_component.save
    end

    render :nothing => true
  end
  
  def toggle_field
    @site_component = SiteComponent.find(params[:id])
    if params[:field] 
      if @site_component.update_attributes("#{params[:field]}" => (@site_component[params[:field]] == 0 or not @site_component[params[:field]] ? true : false))
        flash[:notice] = t"successfully_updated"
      else
        flash[:notice] = t"error_updating_object"
      end
    end
    redirect_back_or_default site_site_components_path(@site)
  end
end

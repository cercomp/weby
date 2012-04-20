class ComponentsController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

  def index
    @components = @site.components.order('position asc')
  end

  def show
    @component = Weby::Components.factory(@site.components.find(params[:id]))
  end

  def new
    if (comp = params[:component])
      @component = Weby::Components.factory(comp)
    else
      render :available_components
    end
  end

  def edit
    @component = Weby::Components.factory(@site.components.find(params[:id]))
  end

  def create
    if (comp = params[:component])
      # cria uma nova instância do componente selecionado
      @component = Weby::Components.factory(comp)
      @component.attributes = params["#{comp}_component"]

      if @component.save
        # TODO colocar tradução na mensagem de sucesso
        redirect_to(site_components_url, :notice => 'Componente criado com sucesso.')
      else
        render :action => "new"
      end
    else
      render :available_components
    end
  end

  def update
    @component = Weby::Components.factory(@site.components.find(params[:id]))

    comp = params[:component]
    if @component.update_attributes(params["#{comp}_component"])
      # TODO colocar tradução na mensagem de sucesso
      redirect_to(site_components_url, :notice => 'Componente atualizado com sucesso.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @component = Component.find(params[:id])
    @component.destroy

    # TODO tradução
    redirect_to site_components_url, :notice => 'Componente removido com sucesso'
  end
  
  def sort
    @components = @site.components

    params['sort_sites_component'] ||= []
    params['sort_sites_component'].to_a.each do |p|
      component = Component.find(p)
      component.position = (params['sort_sites_component'].index(p) + 1)
      component.save
    end

    render :nothing => true
  end
  
  def toggle_field
    @component = Component.find(params[:id])
    if params[:field] 
      if @component.update_attributes("#{params[:field]}" => (@component[params[:field]] == 0 or not @component[params[:field]] ? true : false))
        flash[:notice] = t"successfully_updated"
      else
        flash[:notice] = t"error_updating_object"
      end
    end
    redirect_back_or_default site_components_path(@site)
  end
end

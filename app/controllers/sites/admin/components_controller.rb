# encoding: UTF-8
class Sites::Admin::ComponentsController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization

  def index
    @components = @site.components.order('position asc')
  end

  def show
    @component = Weby::Components.factory(@site.components.find(params[:id]))
  end

  def new
    if (params[:component] and Weby::Components.is_enabled?(params[:component]))
      @component = Weby::Components.factory(params[:component])
    else
      render :available_components
    end
  end

  def edit
    @component = Weby::Components.factory(@site.components.find(params[:id]))
    unless(Weby::Components.is_enabled?(@component.name))
      flash[:warning] = t("disabled_component")
      redirect_to site_admin_components_url
    end
  end

  def create
    if (comp = params[:component])
      # cria uma nova instância do componente selecionado
      @component = Weby::Components.factory(comp)
      @component.attributes = params["#{comp}_component"]

      if @component.save
        redirect_to(site_admin_components_path, flash: {success: t('successfully_created_param', param: t('component.one'))})
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
      redirect_to(site_admin_components_path, flash: {success: t('successfully_updated_param', param: t('component.one'))})
    else
      render :action => "edit"
    end
  end

  def destroy
    @component = Component.find(params[:id])
    @component.destroy

    redirect_to site_admin_components_path, flash: {success: t('successfully_removed', param: t('component.one'))}
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
      if @component.toggle!(params[:field])
        flash[:success] = t"successfully_updated"
      else
        flash[:error] = t"error_updating_object"
      end
    end
    redirect_to :back
  end
end

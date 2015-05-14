# encoding: UTF-8
class Sites::Admin::ComponentsController < ApplicationController
  include ActsToToggle

  before_action :require_user
  before_action :check_authorization

  def index
    @components = current_site.active_skin.components.order(position: :asc)
    @placeholders = current_site.theme.layout['placeholders']
  end

  def show
    # @component = Weby::Components.factory(current_site.components.find(params[:id]))
    redirect_to site_admin_components_path
  end

  def new
    if params[:component] && component_is_available(params[:component])
      @component = Weby::Components.factory(params[:component])
      @component.place_holder = params[:placeholder]
    else
      render :available_components
    end
  end

  def edit
    @component = Weby::Components.factory(current_site.active_skin.components.find(params[:id]))
    unless component_is_available(@component.name)
      flash[:warning] = t('.disabled_component')
      redirect_to site_admin_components_url
    end
  end

  def create
    if params[:component]
      # creates an new instance of the selected component
      @component = Weby::Components.factory(params[:component])
      @component.attributes = component_params
      @component.skin = current_site.active_skin

      if @component.save
        record_activity('created_component', @component)
        redirect_to(site_admin_components_path, flash: { success: t('successfully_created_param', param: t('component')) })
      else
        render action: 'new'
      end
    else
      render :available_components
    end
  end

  def update
    @component = Weby::Components.factory(current_site.active_skin.components.find(params[:id]))

    update_params

    if @component.update(component_params)
      record_activity('updated_component', @component)
      redirect_to(site_admin_components_path, flash: { success: t('successfully_updated_param', param: t('component')) })
    else
      render action: 'edit'
    end
  end

  def destroy
    @component = Component.find(params[:id])
    if @component.destroy
      record_activity('destroyed_component', @component)
    end

    redirect_to site_admin_components_path, flash: { success: t('successfully_removed', param: t('component')) }
  end

  def sort
    Component.update_positions(params['sort_sites_component'] || [], params[:place_holder])

    render nothing: true
  end

  private

  # TODO: Review this method
  # Used to add especific component's code as the component don't have an controller
  def update_params
    params[:feedback_component][:groups_id] ||= nil if params[:feedback_component]
    params[:photo_slider_component][:photo_ids] ||= [] if params[:photo_slider_component]
  end

  def component_params
    params["#{params[:component]}_component"].permit!
  end
end

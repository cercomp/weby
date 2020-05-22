# encoding: UTF-8
class Sites::Admin::ComponentsController < ApplicationController
  include ActsToToggle

  before_action :require_user
  before_action :check_authorization
  before_action :load_skin, only: [:new, :create]
  before_action :load_component, only: [:show, :edit, :update, :destroy]

  def show
    redirect_to site_admin_skin_path(@skin, anchor: 'tab-layout')
  end

  def new
    if params[:component] && component_is_available(params[:component])
      @component = Weby::Components.factory(params[:component])
      @component.place_holder = params[:placeholder]
      @component.skin = @skin
    elsif params[:component].to_s.match(/^components_template/) && components_template_is_available(@skin, params[:component])
      @name = params[:component].split('|').second
      render :new_components_template
    else
      render :available_components
    end
  end

  def edit
    @component = Weby::Components.factory(@component)
    unless component_is_available(@component.name)
      flash[:warning] = t('.disabled_component')
      redirect_to site_admin_skin_path(@skin, anchor: 'tab-layout')
    end
  end

  def create
    if params[:component].present?
      if params[:component].match(/^components_template/) && components_template_is_available(@skin, params[:component])
        @name = params[:component].split('|').second
        if params[:place_holder].present?
          @skin.base_theme&.insert_components_template(@skin, @name, params[:place_holder])
          #record_activity('created_component', @component)
          redirect_to(site_admin_skin_path(@skin, anchor: 'tab-layout'), flash: { success: t('successfully_created_param', param: t('component')) })
        else
          flash[:warning] = t('.select_placeholder')
          render :new_components_template
        end
      else
        # creates an new instance of the selected component
        @component = Weby::Components.factory(params[:component])
        @component.attributes = component_params
        @component.skin = @skin

        if @component.save
          record_activity('created_component', @component)
          redirect_to(site_admin_skin_path(@skin, anchor: 'tab-layout'), flash: { success: t('successfully_created_param', param: t('component')) })
        else
          render action: 'new'
        end
      end
    else
      render :available_components
    end
  end

  def update
    @component = Weby::Components.factory(@component)

    update_params

    if @component.update(component_params)
      record_activity('updated_component', @component)
      redirect_to(site_admin_skin_path(@skin, anchor: 'tab-layout'), flash: { success: t('successfully_updated_param', param: t('component')) })
    else
      render action: 'edit'
    end
  end

  def destroy
    if @component.destroy
      record_activity('destroyed_component', @component)
    end

    redirect_to site_admin_skin_path(@skin, anchor: 'tab-layout'), flash: { success: t('successfully_removed', param: t('component')) }
  end

  def sort
    Component.update_positions(params['sort_sites_component'] || [], params[:place_holder])

    head :ok
  end

  private

  def load_skin
    @skin = current_site.skins.find(params[:skin_id])
  end

  def load_component
    load_skin
    @component = @skin.components.find(params[:id])
  end

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

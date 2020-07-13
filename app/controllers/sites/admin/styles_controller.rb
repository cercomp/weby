class Sites::Admin::StylesController < ApplicationController
  before_action :require_user
  before_action :check_authorization
  before_action :load_skin, only: [:index, :new, :create, :sort, :toggle]
  before_action :load_global_style, only: [:show, :follow, :copy, :unfollow]
  before_action :load_style, only: [:edit, :update, :destroy]

  include ActsToToggle

  respond_to :html, :xml, :js

  def index
    redirect_to site_admin_skin_path(@skin, anchor: 'tab-styles')
  end

  def show
  end

  def new
    @style = @skin.styles.new
  end

  def create
    @style = @skin.styles.new(style_params)
    if @style.save
      flash[:success] = t('successfully_created')
      record_activity('created_style', @style)
      redirect_to edit_site_admin_skin_style_path(@skin, @style)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @style.update(style_params)
        record_activity('updated_style', @style)
        format.html do
          flash[:success] = t('successfully_updated')
          redirect_to site_admin_skin_path(@skin, anchor: 'tab-styles')
        end
        format.json do
          render json: {ok: true, message: t('successfully_updated'), icon: ActionController::Base.helpers.asset_url('true.png')}
        end
      else
        format.html do
          render 'edit'
        end
        format.json do
          msg = "#{t("simple_form.error_notification.default_message")}<br/>#{@style.errors.full_messages.join('<br/>')}"
          render json: {ok: false, message: msg, icon: ActionController::Base.helpers.asset_url('false.png')}
        end
      end
    rescue
      format.json do
        msg = "#{t("simple_form.error_notification.default_message")}<br/>#{@style.errors.full_messages.join('<br/>')}"
        render status: 500, json: {ok: false, message: msg, icon: ActionController::Base.helpers.asset_url('false.png')}
      end
    end
  end

  def destroy
    if resource.destroy
      flash[:success] = t('destroyed_style')
      record_activity('destroyed_style', resource)
    else
      flash[:error] = t('destroyed_style_error')
    end

    respond_with(:site_admin, resource, location: site_admin_skin_path(@skin, anchor: 'tab-styles'))
  end

  def unfollow
    if @style.owner == current_site
      flash[:error] = t('error_unfollowing_style')
      redirect_back(fallback_location: site_admin_skin_path(@skin, anchor: 'tab-styles'))
    else
      destroy
    end
  end

  def follow
    new_style = @current_skin.styles.new(style_id: @style.id)
    if new_style.save
      record_activity('followed_style', new_style)
      flash[:success] = t('successfully_followed')
    else
      flash[:error] = new_style.errors.full_messages.join(', ')
    end
    redirect_to site_admin_skin_path(@current_skin, anchor: 'tab-styles', others: true)
  end

  def copy
    if ( new_style = @style.copy!(@current_skin) )
      record_activity('copied_style', new_style)
      flash[:success] = t('successfully_copied')
    else
      flash[:error] = t('error_copying_style')
    end
    redirect_to site_admin_skin_path(@current_skin, anchor: 'tab-styles')
  end

  def sort
    position = 0
    params['sort_style'].reverse_each do |style_id|
      @skin.styles.find(style_id).update_attribute(:position, position += 1)
    end
    head :ok
  end

  private

  def load_skin
    @skin = current_site.skins.find(params[:skin_id])
  end

  # loads the style/skin with the same theme as the style from other site
  def load_global_style
    @style = Style.find params[:id]
    @skin = @style.skin
    @current_skin = current_site.skins.find_by(theme: @skin.theme)
  end

  def load_style
    load_skin
    @style = @skin.styles.own.find(params[:id])
  end

  # override method from concern to work with relation
  def resource
    get_resource_ivar || set_resource_ivar(@skin.styles.find(params[:id]))
  end

  def after_toggle_path
    load_skin if @skin.blank?
    site_admin_skin_path(@skin, anchor: 'tab-styles')
  end

  def style_params
    params.require(:style).permit(:name, :publish, :css)
  end
end

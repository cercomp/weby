class Sites::Admin::StylesController < ApplicationController
  include ActsToToggle

  before_action :require_user
  before_action :check_authorization

  respond_to :html, :xml, :js

  def index
    @styles = {}
    @styles[:others] = Style.not_followed_by(current_site).search(params[:search]).
                        page(params[:page]).per(params[:per_page])
    @styles[:styles] = current_site.styles.includes(:site, :style, :followers) if request.format.html?
  end

  def show
    @style = Style.find params[:id]
  end

  def new
    @style = current_site.styles.new
  end

  def create
    @style = current_site.styles.new(params[:style])
    if @style.save
      flash[:success] = t('successfully_created')
      record_activity('created_style', @style)
      redirect_to edit_site_admin_style_path(@style)
    else
      render 'new'
    end
  end

  def edit
    @style = current_site.styles.own.find params[:id]
  end

  def update
    @style = current_site.styles.own.find params[:id]
    respond_to do |format|
      if @style.update(params[:style])
        record_activity('updated_style', @style)
        format.html do
          flash[:success] = t('successfully_updated')
          redirect_to site_admin_styles_path
        end
      else
        format.html { render 'edit' }
      end
      format.json { render text: @style.errors.full_messages.to_json }
    end
  end

  def destroy
    if resource.destroy
      flash[:success] = t('destroyed_style')
      record_activity('destroyed_style', resource)
    else
      flash[:error] = t('destroyed_style_error')
    end

    respond_with(:site_admin, resource, location: site_admin_styles_path)
  end

  def follow
    resource = Style.find params[:id]
    @style = current_site.styles.new(style_id: resource.id)
    if @style.save
      flash[:success] = t('successfully_followed')
    else
      flash[:error] = @style.errors.full_messages.join(', ')
    end
    redirect_to site_admin_styles_path(others: true)
  end

  def unfollow
    if resource.owner == current_site
      flash[:error] = t('error_unfollowing_style')
      redirect_to :back
    else
      destroy
    end
  end

  def copy
    if Style.find(params[:id]).copy! current_site
      flash[:success] = t('successfully_copied')
    else
      flash[:error] = t('error_copying_style')
    end
    redirect_to site_admin_styles_path
  end

  def sort
    position = 0
    params['sort_style'].reverse_each do |style_id|
      current_site.styles.find(style_id).update_attribute(:position, position += 1)
    end
    render nothing: true
  end

  private

  # override method from concern to work with relation
  def resource
    get_resource_ivar || set_resource_ivar(current_site.styles.find(params[:id]))
  end

  def after_toggle_path
    site_admin_styles_path
  end
end

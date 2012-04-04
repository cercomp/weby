class StylesController < ApplicationController
  layout :choose_layout

  before_filter :require_user
  before_filter :check_authorization
  before_filter :verify_ownership, only: [:edit, :update, :destroy]

  respond_to :html, :xml, :js

  def index
    return only_selected_style if params[:style_type]
    @styles = {
      own: own_styles,
      follow: follow_styles,
      other: other_styles
    }    
  end

  def only_selected_style
    @styles = {
      params[:style_type].to_sym => send("#{params[:style_type]}_styles")
    }
  end

  # FIXME: duplicated code
  def own_styles
    styles = @site.own_styles.scoped.
      order(:id).page(params[:page_own_styles]).per(5)

    search(styles, :own) || styles
  end
  private :own_styles

  # FIXME: duplicated code
  def follow_styles
    styles = @site.follow_styles.scoped.
      order(:id).page(params[:page_follow_styles]).per(5)

    search(styles, :follow) || styles
  end
  private :follow_styles

  # FIXME: duplicated code
  def other_styles
    styles = Style.not_followed_by(@site).
      order(:id).page(params[:page_other_styles]).per(5)

    search(styles, :other) || styles
  end
  private :other_styles

  def search(styles, type)
    if params[:style_type] == type.to_s && params[:style_name]
    styles.by_name(params[:style_name]) if params[:style_type] == type.to_s
  end
  private :search

  def show
    @style = Style.find(params[:id])
  end

  def new
    @style = Style.new
  end

  def edit
    @style = Style.find(params[:id])
  end

  def create
    @style = Style.new(params[:style])

    if @style.save
      flash[:notice] = t('successfully_created')
      redirect_to site_styles_path
    else
      render site_id: @site.id, controller: 'styles', action: 'new'
    end
  end

  def update
    @style = Style.find(params[:id])

    if @style.update_attributes(params[:style])
      flash[:notice] = t('successfully_updated')
      redirect_to site_styles_path 
    else
      render site_id: @site.id, controller: 'styles', action: 'edit'
    end
  end

  def destroy
    @style = Style.find(params[:id])

    if @style.destroy
      flash[:notice] = t('destroyed_param', param: t('style.one'))
    else
      flash[:alert] = t('destroyed_param_error', param: t('style.one'))
    end

    redirect_to site_styles_path(@site)
  end

  def follow
    @style = Style.find(params[:id])
    @site.follow_styles << @style

    redirect_to site_styles_path(@site)
  end

  def unfollow
    @style = Style.find(params[:id])
    @site_style = @style.sites_styles.where(site_id: @site.id).first
    @site_style.destroy

    redirect_to site_styles_path(@site)
  end

  def publish
    @style = Style.find(params[:id])
    @style = @style.sites_styles.where(site_id: @site.id).first if @style.owner != @site
    @style.update_attributes(publish: true)

    redirect_to site_styles_path(@site)
  end

  def unpublish
    @style = Style.find(params[:id])
    @style = @style.sites_styles.where(site_id: @site.id).first if @style.owner != @site
    @style.update_attributes(publish: false)

    redirect_to site_styles_path(@site)
  end

  def copy
    @style = Style.find(params[:id]).dup
    @style.owner = @site
    @style.publish = false

    if @style.save
      flash[:notice] = t('successfully_created')
    else
      flash[:notice] = t('error_creating_object')
    end

    redirect_to site_styles_path(@site)
  end

  private
  def verify_ownership
    @style = Style.find(params[:id])

    unless @style.owner == @site
      flash[:warning] = t('no_permission_to_action')
      redirect_to site_style_url
    end
  end
end

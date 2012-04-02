class StylesController < ApplicationController
  layout :choose_layout

  before_filter :require_user
  before_filter :check_authorization
  before_filter :verify_ownership, only: [:edit, :update, :destroy]

  respond_to :html, :xml, :js

  # FIXME: always execute all methods
  def index
    @styles = {
      own: own_styles,
      follow: follow_styles,
      other: other_styles
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
      order(:id).page(params[:page_other_styles]).per(2)

    search(styles, :other) || styles
  end
  private :other_styles

  def search(styles, type)
    styles.by_name(params[:style_name]) if params[:style_type] == type.to_s
  end
  private :search

  #def index
    #@style_type = params[:style_type]
    #p @style_type
    #p params[:page_other_style]

    #@follow_styles = @site.follow_styles.scoped.
      #order(:id).page(params[:page_follow_style]).per(5)

    #@other_styles = Style.not_followed_by(@site).
      #order(:id).page(params[:page_other_style]).per(2)

    #case @style_type
    #when 'own'
      #@own_styles = @own_styles.by_name(params[:style_name])
    #when 'follow'
      #@follow_styles = @follow_styles.by_name(params[:style_name])
    #when 'other'
      #@other_styles = @other_styles.by_name(params[:style_name])
    #end
  #end

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

    redirect_back_or_default site_styles_path(@site)
  end

  def unfollow
    @style = Style.find(params[:id])
    @site_style = @style.sites_styles.where(site_id: @site.id).first
    @site_style.destroy

    redirect_back_or_default site_styles_path(@site)
  end

  def publish
    @style = Style.find(params[:id])
    @style = @style.sites_styles.where(site_id: @site.id).first if @style.owner != @site
    @style.update_attributes(publish: true)

    redirect_back_or_default site_styles_path(@site)
  end

  def unpublish
    @style = Style.find(params[:id])
    @style = @style.sites_styles.where(site_id: @site.id).first if @style.owner != @site
    @style.update_attributes(publish: false)

    redirect_back_or_default site_styles_path(@site)
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

    redirect_back_or_default site_styles_path(@site)
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

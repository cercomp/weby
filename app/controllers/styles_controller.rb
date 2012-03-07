class StylesController < ApplicationController
  layout :choose_layout

  before_filter :require_user
  before_filter :check_authorization

  # Verify if current site is owner of the edited/updated style
  before_filter :verify_ownership, :only => [:edit, :update, :destroy]

  respond_to :html, :xml, :js

  def index
    @my_style_name = params[:my_style_name]
    @other_style_name = params[:other_style_name]

    @my_styles = @site.my_styles.
      joins(:style).
      where(['styles.name like ?', "%#{params[:my_style_name]}%"]).
      order(:id).
      page(params[:page_my_styles] || 1).
      per(15)

    @other_styles = @site.other_styles.
      joins(:style).where(['styles.name like ?', "%#{params[:other_style_name]}%"]).
      order(:id).
      page(params[:page_other_styles] || 1).
      per(15)

    respond_to do |format|
      format.html 
      format.js
      format.xml  { render :xml => @styles }
    end
  end

  def show
    @style = Style.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @style }
    end
  end

  def new
    @style = Style.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @style }
    end
  end

  def edit
    @style = Style.find(params[:id])
  end

  def create
    @style = Style.new(params[:style])
    @style.sites_styles.build(:site_id => @site.id, :owner => true, :publish => true)

    respond_to do |format|
      if @style.save
        format.html { redirect_to(site_styles_path, :notice => t('successfully_created')) }
        format.xml  { render :xml => @style, :status => :created, :location => @style }
      else
        format.html { render :site_id => @site.id, :controller => 'styles', :action => 'new' }
        format.xml  { render :xml => @style.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @style = Style.find(params[:id])

    respond_to do |format|
      if @style.update_attributes(params[:style])
        format.html { redirect_to(site_styles_path, :notice => "Atualizado com sucesso" ) }
        format.xml  { head :ok }
      else
        format.html { redirect_to :back }
        format.xml  { render :xml => @style.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @style = Style.find(params[:id])

    # Verify if this style has more that one site
    if @style.sites.count > 1
      flash[:warning] = t("no_permission_to_action")
      redirect_to site_styles_url

    else
      if @style.destroy
        flash[:notice] = t("destroyed_param", :param => t("style.one"))
      else
        flash[:alert] = t("destroyed_param_error", :param => t("style.one"))
      end

      redirect_to site_styles_path(@site)
    end
  end

  def toggle_field
    @style = SitesStyle.find(params[:id])

    if params[:field]
      if @style.update_attributes("#{params[:field]}" => (@style[params[:field]] == 0 or not @style[params[:field]] ? true : false))
        flash[:notice] = t"successfully_updated"
      else
        flash[:notice] = t"error_updating_object"
      end
    end

    redirect_back_or_default site_styles_path(@site)
  end

  def follow
    @stylerel = SitesStyle.find(params[:id])

    if params[:following] == "true"
      @style = @stylerel.style.sites_styles.where(:site_id => @site.id).first
      @style.destroy
    else
      @style = @stylerel.style
      @style.sites_styles.create(:site_id => @site.id, :publish => "true", :owner => "false" )

      if @style.save
        flash[:notice] = t"successfully_updated"
      else
       flash[:notice] = t"error_updating_object"
      end
    end

    redirect_back_or_default site_styles_path(@site)
  end

  def copy
    @style = Style.find(params[:id]).clone

    if @style.save
      @style.sites_styles.create(:site_id => @site.id, :publish => "true", :owner => "true" )
      if @style.save
        flash[:notice] = t"successfully_created"
      else
        flash[:notice] = t"error_creating_object"
      end
    else
      flash[:notice] = t"error_creating_object"
    end

    redirect_back_or_default site_styles_path(@site)
  end

  private
  def verify_ownership
    @style = Style.find(params[:id])

    logger.debug @style.owner

    unless @site.id == @style.owner.id
      flash[:warning] = t("no_permission_to_action")
      redirect_to site_style_url
    end
  end
end

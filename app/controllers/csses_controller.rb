class CssesController < ApplicationController
  layout :choose_layout

  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml

  def index
    @my_csses = @site.sites_csses.where('owner=true')

    @used_csses = SitesCss.where(:css_id => @site.sites_csses.where('owner=false').group_by(&:css_id).keys, :owner => :true)

    keys = (SitesCss.where('owner=true') - @my_csses).group_by(&:css_id).keys - @used_csses.group_by(&:css_id).keys
    @other_csses = SitesCss.where(:css_id => keys, :owner => :true)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @csses }
    end
  end

  def show
    @css = Css.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @css }
    end
  end

  def new
    @css = Css.new
    @css.sites_csses.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @css }
    end
  end

  def edit
    @css = Css.find(params[:id])
  end

  def create
    @css = Css.new(params[:css])

    respond_to do |format|
      if @css.save
        format.html { redirect_to(site_csses_path, :notice => t('successfully_created')) }
        format.xml  { render :xml => @css, :status => :created, :location => @css }
      else
        format.html { render :site_id => @site.id, :controller => 'csses', :action => 'new' }
        format.xml  { render :xml => @css.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @css = Css.find(params[:id])

    respond_to do |format|
      if @css.update_attributes(params[:css])
        format.html { redirect_to(site_csses_path, :notice => t('successfully_updated')) }
        format.xml  { head :ok }
      else
        format.html { redirect_to :back }
        format.xml  { render :xml => @css.errors, :status => :unprocessable_entity }
      end
    end
  end

  def toggle_field
    @css = SitesCss.find(params[:id])

    if params[:field]
      if @css.update_attributes("#{params[:field]}" => (@css[params[:field]] == 0 or not @css[params[:field]] ? true : false))
        flash[:notice] = t"successfully_updated"
      else
        flash[:notice] = t"error_updating_object"
      end
    end

    redirect_back_or_default site_csses_path(@site)
  end

  def follow
    @cssrel = SitesCss.find(params[:id])

    if params[:following] == "true"
      @css = @cssrel.css.sites_csses.where(:site_id => @site.id).first
      @css.destroy
    else
      @css = @cssrel.css
      @css.sites_csses.create(:site_id => @site.id, :publish => "true", :owner => "false" )

      if @css.save
        flash[:notice] = t"successfully_updated"
      else
        flash[:notice] = t"error_updating_object"
      end
    end

    redirect_back_or_default site_csses_path(@site)
  end

  def copy
    @css = Css.find(params[:id]).clone

    if @css.save
      @css.sites_csses.create(:site_id => @site.id, :publish => "true", :owner => "true" )
      if @css.save
        flash[:notice] = t"successfully_created"
      else
        flash[:notice] = t"error_creating_object"
      end
    else
      flash[:notice] = t"error_creating_object"
    end

    redirect_back_or_default site_csses_path(@site)
  end
end

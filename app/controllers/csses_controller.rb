class CssesController < ApplicationController
  layout :choose_layout

  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml, :js

  def index
    @my_css_name = params[:my_css_name]
    @other_css_name = params[:other_css_name]

    @my_csses = @site.my_csses.
      joins(:css).
      where(['csses.name like ?', "%#{params[:my_css_name]}%"]).
      order(:id).
      page(params[:page_my_csses] || 1).
      per(15)

    @other_csses = @site.other_csses.
      joins(:css).where(['csses.name like ?', "%#{params[:other_css_name]}%"]).
      order(:id).
      page(params[:page_other_csses] || 1).
      per(15)

    respond_to do |format|
      format.html 
      format.js
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

class CssesController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization
  respond_to :html, :xml

  def index
    @csses = Css.paginate :page => params[:page], :per_page => 10

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

  def destroy
    @css = Css.find(params[:id])
    @css.destroy

    respond_to do |format|
      format.html { redirect_to(site_csses_path) }
      format.xml  { head :ok }
    end
  end

  def toggle_field
    @css = Css.find(params[:id])
    if params[:field] 
      if @css.update_attributes("#{params[:field]}" => (@css[params[:field]] == 0 or not @css[params[:field]] ? true : false))
        flash[:notice] = t"successfully_updated"
      else
        flash[:notice] = t"error_updating_object"
      end
    end
    redirect_back_or_default site_csses_path(@site)
  end

  def use_css
    @css = Css.find(params[:id])
    @css.sites_csses.create(:site_id => @site.id)

    if @css.save
      flash[:notice] = t"successfully_updated"
    else
      flash[:notice] = t"error_updating_object"
    end

    redirect_back_or_default site_csses_path(@site)
  end
end

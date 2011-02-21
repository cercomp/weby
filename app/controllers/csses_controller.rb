class CssesController < ApplicationController
  layout :choose_layout

  respond_to :html, :xml, :js
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
        format.html {
          redirect_to({:site_id => @css.site.name, :controller => 'csses', :action => 'index'},
                      :notice => t('successfully_created')) }
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
        format.html {
         redirect_to({:site_id => @css.site.name, :controller => 'csses', :action => 'index'},
                     :notice => t('successfully_updated')) }
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
      format.html { redirect_to(site_csses_url) }
      format.xml  { head :ok }
    end
  end

end

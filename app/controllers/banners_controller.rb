class BannersController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml, :js

  # GET /banners
  # GET /banners.xml
  def index
    @banners = @site.banners.paginate :page => params[:page], :per_page => 10

    respond_with do |format|
      format.js { 
        render :update do |site|
          site.call "$('#list').html", render(:partial => 'list')
        end
      }
      format.xml  { render :xml => @banners }
      format.html
    end
  end

  # GET /banners/1
  # GET /banners/1.xml
  def show
    @banner = Banner.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @banner }
    end
  end

  # GET /banners/new
  # GET /banners/new.xml
  def new
    @banner = Banner.new
    @banner.sites_banners.build
    @repositories = Repository.where(["site_id = ? AND archive_content_type LIKE ?", @site.id, "image%"]).paginate :page => params[:page], :order => 'created_at DESC', :per_page => 4 

    respond_with do |format|
      format.js { 
        render :update do |page|
          page.call "$('#repo_list').html", render(:partial => 'pages/repo_list', :locals => { :f => SemanticFormBuilder.new(:banner, @banner, self, {}, proc{}) })
        end
      }
      format.html
      format.xml  { render :xml => @banner }
    end
  end

  # GET /banners/1/edit
  def edit
    @repositories = Repository.where(["site_id = ? AND archive_content_type LIKE ?", @site.id, "image%"]).paginate :page => params[:page], :order => 'created_at DESC', :per_page => 4 
    @banner = Banner.find(params[:id])
    @banner.sites_banners.build

    respond_with do |format|
      format.js { 
        render :update do |page|
          page.call "$('#repo_list').html", render(:partial => 'pages/repo_list', :locals => { :f => SemanticFormBuilder.new(:banner, @banner, self, {}, proc{}) })
        end
      }
      format.html
      format.xml  { render :xml => @banner, :status => :created, :location => @banner }
    end
  end

  # POST /banners
  # POST /banners.xml
  def create
    @repositories = Repository.where(["site_id = ? AND archive_content_type LIKE ?", @site.id, "image%"]).paginate :page => params[:page], :order => 'created_at DESC', :per_page => 4 
    @banner = Banner.new(params[:banner])
    @banner.save
    respond_with(@site, @banner)
  end

  # PUT /banners/1
  # PUT /banners/1.xml
  def update
    @repositories = Repository.where(["site_id = ? AND archive_content_type LIKE ?", @site.id, "image%"]).paginate :page => params[:page], :order => 'created_at DESC', :per_page => 4 
    @banner = Banner.find(params[:id])

    respond_to do |format|
      if @banner.update_attributes(params[:banner])
        format.html { redirect_to([@site, @banner], :notice => t("successfully_updated")) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @banner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /banners/1
  # DELETE /banners/1.xml
  def destroy
    @banner = Banner.find(params[:id])
    @banner.destroy

    respond_to do |format|
      format.html { redirect_to(site_banners_path(@site)) }
      format.xml  { head :ok }
    end
  end

  def toggle_field
    @banner = Banner.find(params[:id])
    if params[:field] 
      if @banner.update_attributes("#{params[:field]}" => (@banner[params[:field]] == 0 or not @banner[params[:field]] ? true : false))
        flash[:notice] = t"successfully_updated"
      else
        flash[:notice] = t"error_updating_object"
      end
    end
    redirect_to :back
  end
end

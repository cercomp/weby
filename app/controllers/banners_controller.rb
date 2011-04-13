class BannersController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization
  before_filter :repositories, :only => ['new', 'edit', 'create', 'update']

  helper_method :sort_column

  respond_to :html, :xml, :js

  def index
    @banners = @site.banners.unscoped.order(sort_column + " " + sort_direction).
      page(params[:page]).per(per_page)

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

  def show
    @banner = Banner.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @banner }
    end
  end

  def new
    @banner = Banner.new

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

  def edit
    @banner = Banner.find(params[:id])

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

  def create
    @banner = Banner.new(params[:banner])
    @banner.save
    respond_with(@site, @banner)
  end

  def update
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

  private
  def sort_column
    Banner.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def per_page
    unless params[:per_page]
      @tiny_mce ? 5 : per_page_array.first
    else
      params[:per_page]
    end
  end

  def repositories
    @repositories = Repository.where(["site_id = ? AND archive_content_type LIKE ?", @site.id, "image%"]).page(params[:page]).per(per_page)
  end
end

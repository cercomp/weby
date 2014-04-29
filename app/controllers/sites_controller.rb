class SitesController < ApplicationController
  layout :choose_layout, only: :show
  
  before_filter :require_user, only: [:admin, :edit, :update]
  before_filter :check_authorization, only: [:edit, :update]
  
  respond_to :html, :xml, :js

  helper_method :sort_column

  #### FRONT-END

  def index
    params[:page] ||= 1

    #TODO Pesquisar também no título das notícias
    @sites = Site.ordered_by_front_pages(params[:search])
    @sites = list_sites(@sites)
    @default_groupings = Weby::Settings.default_groupings
    if params[:groupings]
      @sites = @sites.includes(:groupings).where(groupings: {id: params[:groupings].split(',')}) unless params[:groupings] == 'all'
    else
      if @default_groupings
        if @default_groupings.match(/^!/)
          @sites = @sites.includes(:groupings).where("(groupings.id NOT IN (?) OR groupings.id IS NULL)", @default_groupings.gsub(/^!/, '').split(','))
        else
          @sites = @sites.includes(:groupings).where(groupings: {id: @default_groupings.split(',')})
        end
      end
    end

    @sites = Kaminari.paginate_array(@sites).page(params[:page]).per(18)

    @nexturl = sites_path(page: params[:page].to_i+1, search: params[:search], groupings: params[:groupings])
    
    if request.xhr?
      render partial: 'list', layout: false
    else
  @my_sites = current_user ? current_user.sites : []

      @groupings = Grouping.all

      render layout: 'weby_pages'
    end
  end

  def show
    raise ActiveRecord::RecordNotFound unless @site
    params[:id] = @site.id
    params[:per_page] = nil
  end
  
  def robots
    robots_file = Rails.root.join("public", "uploads", current_site.id.to_s, "original_robots.txt") if current_site

    #render file: (robots_file && FileTest.exist?(robots_file) ?
    #  robots_file : Rails.root.join("public","default_robots.txt")), :layout => false, :content_type => "text/plain"
    render text: File.read(robots_file && FileTest.exist?(robots_file) ?
      robots_file : Rails.root.join("public","default_robots.txt")), :layout => false, :content_type => "text/plain"

  end

  def about
    render partial: 'layouts/shared/about'
  end

  #### BACK-END

  def admin
    render layout: "application"
  end

  def edit
    @site = current_site
    load_themes
    @sites = @site.subsites.
      except(:order).
      order("#{sort_column} #{sort_direction}").
      page(params[:page]).
      per(params[:per_page])

    render layout: "application"
  end

  def update
    @site = current_site
    params[:site][:top_banner_id] ||= nil
    if @site.update_attributes(params[:site])
      flash[:success] = t("successfully_updated")
      redirect_to edit_site_admin_url(subdomain: @site)
    else
      load_themes
      render :edit, layout: "application"
    end
  end

  private
  def sort_column
    Site.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def load_themes
    @themes = Weby::Themes.all
  end
      
  def sites_hidden
  @group = Grouping.all
  ids_hidden = Array.new

  @group.each do |g|
    if g.hidden
      g.site_ids.each do |id|
        ids_hidden << id unless ids_hidden.include?(id)
      end
    end
  end
  ids_hidden
  end
		
  def list_sites(site)
    unless site.nil?
      site = Site.all
    end
    if current_user.blank? || !current_user.is_admin
      sites_hidden.each do |hidden|
        site.delete(Site.find(hidden))
      end
    end
    site
  end
  
end

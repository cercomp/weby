class SitesController < ApplicationController
  layout :choose_layout, only: :show

  before_action :require_user, only: [:admin, :edit, :update]
  before_action :check_authorization, only: [:edit, :update]

  respond_to :html, :xml, :js

  helper_method :sort_column

  #### FRONT-END

  def index
    params[:page] ||= 1

    # TODO Search using the new's tittle too
    @sites = Site.ordered_by_front_pages(params[:search])

    if !current_user || !current_user.is_admin?
      @sites = @sites.visible
    end

    if params[:groupings].present?
      @sites = @sites.includes(:groupings).where(groupings: { id: params[:groupings].split(',') })
    end

    @sites = @sites.page(params[:page]).per(18)

    @nexturl = sites_path(page: params[:page].to_i + 1, search: params[:search], groupings: params[:groupings])

    if request.xhr?
      render partial: 'list', layout: false
    else
      @my_sites = current_user ? current_user.sites : []

      @groupings = current_user && current_user.is_admin? ? Grouping.all : Grouping.visible

      render layout: 'weby_pages'
    end
  end

  def show
    fail ActiveRecord::RecordNotFound unless @site
    params[:id] = @site.id
    params[:per_page] = nil
  end

  def robots
    robots_file = Rails.root.join('public', 'up', current_site.id.to_s, 'o', 'robots.txt') if current_site

    # render file: (robots_file && FileTest.exist?(robots_file) ?
    #  robots_file : Rails.root.join("public","default_robots.txt")), layout: false, content_type: "text/plain"
    render text: File.read(robots_file && FileTest.exist?(robots_file) ? robots_file : Rails.root.join('public', 'default_robots.txt')), layout: false, content_type: 'text/plain'
  end

  def admin
    render layout: 'application'
  end

  def edit
    @site = current_site
    load_themes
    @sites = @site.subsites
      .except(:order)
      .order("#{sort_column} #{sort_direction}")
      .page(params[:page])
      .per(params[:per_page])

    render layout: 'application'
  end

  def update
    @site = current_site
    params[:site][:top_banner_id] ||= nil
    if @site.update(site_params)
      flash[:success] = t('successfully_updated')
      redirect_to edit_site_admin_url(subdomain: @site)
    else
      load_themes
      render :edit, layout: 'application'
    end
  end

  private

  def sort_column
    Site.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def load_themes
    @themes = Weby::Themes.all
  end

  def site_params
    params.require(:site).permit(:title, :top_banner_id, :name, :parent_id, :url,
                                 :domain, :description, :view_desc_pages, :theme,
                                 :body_width, :per_page, :per_page_default,
                                 {grouping_ids: [], locale_ids: []})
  end
end

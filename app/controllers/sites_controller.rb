class SitesController < ApplicationController
  layout :choose_layout, only: :show

  before_action :require_user, only: [:admin, :edit, :update, :destroy_subsite, :update_subsite]
  before_action :check_authorization, only: [:edit, :update]
  before_action :is_admin, only: [:destroy_subsite, :update_subsite]
  before_action :load_subsite, only: [:destroy_subsite, :update_subsite]

  respond_to :html, :xml, :js

  helper_method :sort_column

  #### FRONT-END

  def index
    params[:page] ||= 1

    # TODO Search using the new's title too
    @sites = Site.active.ordered_by_front_pages(params[:search])

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
    custom_robots_file = nil
    if current_site
      # check if using external storage
      if ENV['STORAGE_BUCKET'].present?
        s3 = Aws::S3::Resource.new(
          credentials: Aws::Credentials.new(ENV['STORAGE_ACCESS_KEY'], ENV['STORAGE_ACCESS_SECRET']),
          region: 'us-east-1',
          endpoint: "https://#{ENV['STORAGE_HOST']}",
          force_path_style: true
        )
        bucket = s3.bucket(ENV['STORAGE_BUCKET'])
        file = bucket.object("up/#{current_site.id.to_s}/o/robots.txt")
        if file.exists?
          custom_robots_file = file.get.body.read
        end
      else
        robots_file = Rails.root.join('public', 'up', current_site.id.to_s, 'o', 'robots.txt')
        custom_robots_file = File.read(robots_file) if robots_file && FileTest.exist?(robots_file)
      end
    end

    # render file: (robots_file && FileTest.exist?(robots_file) ?
    # robots_file: Rails.root.join("public","default_robots.txt")), layout: false, content_type: "text/plain"
    render plain: custom_robots_file ? custom_robots_file : File.read(Rails.root.join('public', 'default_robots.txt')), layout: false, content_type: 'text/plain'
  end

  #### BACK-END

  def admin
    fail ActiveRecord::RecordNotFound unless current_site
    @last_repositories = current_site.repositories.last(4)
    @last_activity_records = current_site.activity_records.preload(:loggeable).includes(:user).last(10)
    @last_news = current_site.news.includes(:image, :i18ns).order(id: :asc).last(4)
    @last_banners = current_site.banners.includes(:repository).last(4)
    @last_messages = current_site.messages.last(4)
    @newsletter = current_site.active_skin.components.find_by_name("newsletter")


    render layout: 'application'
  end

  def edit
    @site = current_site
    load_subsites
    render layout: 'application'
  end

  def update
    @site = current_site
    params[:site][:top_banner_id] ||= nil
    if @site.update(site_params)
      flash[:success] = t('successfully_updated')
      redirect_to edit_site_admin_url(subdomain: @site)
    else
      load_subsites
      render :edit, layout: 'application'
    end
  end

  def update_subsite
    if @subsite.update(subsite_params)
      if @subsite.previous_changes["status"] == ["active", "inactive"] # check if status was changed from active to inactive
        ::SiteMailer.site_deactivated(@subsite)
      end
      flash[:success] = t('successfully_updated')
      record_activity('updated_site', @subsite)
    else
      flash[:alert] = t('problem_update_site')
    end
    redirect_to edit_site_admin_path(anchor: 'tab-subsites')
  end

  def destroy_subsite
    begin
      @subsite.unscoped_destroy!
      flash[:success] = t('successfully_deleted')
    rescue ActiveRecord::RecordNotDestroyed => error
      flash[:warning] = "#{t('error_destroying_object')}: #{error.record.errors.full_messages.join(', ')}"
    end
    redirect_to edit_site_admin_path(anchor: 'tab-subsites')
  end

  private

  def sort_column
    Site.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def load_subsites
    @sites = @site.subsites.active
        .includes(:main_site)
        .except(:order)
        .order("#{sort_column} #{sort_direction}")
        .page(params[:page])
        .per(params[:per_page])
  end

  def load_subsite
    @subsite = @site.subsites.find(params[:id])
  end

  def subsite_params
    params.require(:site).permit(:status)
  end

  def site_params
    permitted = [:title, :top_banner_id, :description, :show_pages_author,
                 :show_pages_created_at, :show_pages_updated_at, :body_width,
                 :per_page, :per_page_default, :google_analytics,
                {locale_ids: []}]

    if current_user.is_admin?
      permitted += [:name, :parent_id, :domain, :restrict_theme, grouping_ids: []]
    end

    Site::SHAREABLES.each do |shareable|
      permitted << "#{shareable}_social_share_pos"
      permitted << "#{shareable}_facebook_comments"
      permitted << {"#{shareable}_social_share_networks" => []}
    end

    params.require(:site).permit(permitted)
  end
end

module Sticker::Admin
  class BannersController < ApplicationController
    include ActsToToggle

    helper Sticker::Engine.helpers

    before_action :require_user
    before_action :check_authorization
    before_action :search_images, only: [:new, :edit, :create, :update]

    helper_method :sort_column

    respond_to :html, :xml, :js

    def index
      @banners = current_site.banner_sites
        .includes(:banner)
        .references(:sticker_banners)
        .order(query_sort)
        .titles_or_texts_like(params[:search])
        .page(params[:page]).per(params[:per_page])
    end

    def show
      @banner = current_site.banners.find(params[:id])
      @banner_site = @banner.own_banner_site(@banner)
    end

    def new
      @banner = current_site.banners.new
      @banner.banner_sites.build(site_id: current_site)
    end

    def edit
      @banner = current_site.banners.find(params[:id])
    end

    def create
      @banner = current_site.banners.new(banner_params)
      @banner.site_id = current_site.id
      @banner.user_id = current_user.id
      if params[:submit_search]
        search_images
        render action: :edit
      end

      record_activity('created_banner', @banner) if @banner.save
      respond_with(:admin, @banner)
    end

    def update
      @banner = current_site.banners.find(params[:id])
      if params[:submit_search]
        @banner.attributes = params[:banner]
        search_images
      end
      if @banner.update(banner_params)
        record_activity('updated_banner', @banner)
      end
      respond_with(:admin, @banner)
    end

    # Shows only the published Banners
    def fronts
      @banners = current_site.banner_sites
        .includes(:banner)
        .where(sticker_banners: {publish: true})
        .order('sticker_banner_sites.position desc')
        .titles_or_texts_like(params[:search])
        .page(params[:page]).per(params[:per_page])
    end

    def destroy
      @banner = current_site.banners.find(params[:id])
      if @banner.destroy
        record_activity('destroyed_banner', @banner)
        flash[:success] = t('destroyed_param', param: @banner.title)
      end

      redirect_to(admin_banners_path)
    end

    private

    def sort_column
      (Sticker::BannerSite.column_names + Sticker::Banner.column_names).include?(params[:sort]) ? params[:sort] : 'id'
    end

    def query_sort
      sort_field = if Sticker::BannerSite.column_names.include?(sort_column)
        "sticker_banner_sites.#{sort_column}"
      elsif Sticker::Banner.column_names.include?(sort_column)
        "sticker_banners.#{sort_column}"
      end
      ["#{sort_field} #{sort_direction}", "sticker_banner_sites.position ASC"].join(', ')
    end

    def search_images
      @images = current_site.repositories
        .description_or_filename(params[:image_search])
        .content_file(%w(image flash))
        .page(params[:page]).per(current_site.per_page_default)
    end

    def banner_params
      params.require(:banner).permit(:repository_id, :size, :width, :height, :title, :text,
                                     :url, :target_id, :target_type, :publish, :new_tab,
                                     {banner_sites_attributes: [
                                        :id, :site_id, :category_list, :position, :date_begin_at, :date_end_at
                                     ]}
                                    )
    end
  end
end

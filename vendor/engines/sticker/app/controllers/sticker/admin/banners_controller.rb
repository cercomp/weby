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
      sort = sort_column == 'id' ?  ' ' : (sort_column + ' ' + sort_direction + ', ')
      @banners = Sticker::Banner.where(site_id: current_site)
        .order(sort + 'position ASC')
        .titles_or_texts_like(params[:search])
        .page(params[:page]).per(params[:per_page])
    end

    def show
      @banner = Sticker::Banner.where(site_id: current_site).find(params[:id])
    end

    def new
      @banner = Sticker::Banner.where(site_id: current_site).new
    end

    def edit
      @banner = Sticker::Banner.where(site_id: current_site).find(params[:id])
    end

    def create
      @banner = Sticker::Banner.where(site_id: current_site).new(banner_params)
      @banner.user_id = current_user.id
      if params[:submit_search]
        search_images
        render action: :edit
      end

      record_activity('created_banner', @banner) if @banner.save
      respond_with(:admin, @banner)
    end

    def update
      @banner = Sticker::Banner.where(site_id: current_site).find(params[:id])
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
      @banners = Sticker::Banner.where(site_id: current_site, publish: true)
        .order('position desc')
        .titles_or_texts_like(params[:search])
        .page(params[:page]).per(params[:per_page])
    end

    def destroy
      @banner = Sticker::Banner.where(site_id: current_site).find(params[:id])
      if @banner.destroy
        record_activity('destroyed_banner', @banner)
        flash[:success] = t('destroyed_param', param: @banner.title)
      end

      redirect_to(admin_banners_path)
    end

    private

    def sort_column
      Sticker::Banner.column_names.include?(params[:sort]) ? params[:sort] : 'id'
    end

    def search_images
      @images = current_site.repositories
        .description_or_filename(params[:image_search])
        .content_file(%w(image flash))
        .page(params[:page]).per(current_site.per_page_default)
    end

    def banner_params
      params.require(:banner).permit(:repository_id, :size, :width, :height, :title,
                                     :text, :url, :target_id, :target_type, :category_list,
                                     :position, :publish, :date_begin_at,
                                     :date_end_at, :new_tab)
    end
  end
end

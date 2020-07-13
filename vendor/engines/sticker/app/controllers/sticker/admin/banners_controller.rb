module Sticker::Admin
  class BannersController < ApplicationController
    include ActsToToggle

    helper Sticker::Engine.helpers

    before_action :require_user
    before_action :check_authorization, except: [:share_modal]
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
      @banner_site = @banner.own_banner_site
    end

    def new
      @banner = current_site.banners.new_or_clone(params[:copy_from])
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

    def share_modal
      @banner = current_site.banners.can_share.find(params[:id])
      render layout: false
    end

    def share
      # Check if the banner was already shared
      banner_site = Sticker::BannerSite.find_or_create_by!(site_id: params[:site_id], sticker_banner_id: params[:id])

      tags = unescape_param(params[:tag]).to_s.split(',').map(&:strip)
      if tags.present?
        banner_site.category_list.add(*tags)
        banner_site.save!
      end
      flash[:notice] = t('.banner_shared')
      redirect_back(fallback_location: root_url(subdomain: current_site))
      #render json: {ok: true, message: t('.banner_shared')} #CORS issues
    end

    def unshare
      current_site.banner_sites.where(sticker_banner_id: params[:id]).destroy_all
      flash[:success] = t('.unshared_banner')
      redirect_to admin_banners_path
    end

    # Shows only the published Banners
    def fronts
      @banners = current_site.banner_sites
        .includes(:banner)
        .published
        .order('sticker_banner_sites.position DESC, sticker_banner_sites.created_at DESC')
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

    def destroy_many
      current_site.banner_sites.includes(:banner).where(id: params[:ids].split(',')).each do |bs|
        if bs.banner.site_id == current_site.id
          if bs.banner.destroy
            record_activity('destroyed_banner', bs.banner)
            flash[:success] = t('destroyed_param', param: bs.banner.title)
          end
        else
          if bs.destroy
            flash[:success] = t('.unshared_banner')
          end
        end
      end
      redirect_back(fallback_location: admin_banners_path)
    end

    def sort
      @ch_pos = current_site.banner_sites.find_by(id: params[:id_moved])
      increment = 1
      # In case it was moved to the end of the list or the end of a page (when paginated)
      if (params[:id_after].to_s == '0')
        @before = current_site.banner_sites.find_by(id: params[:id_before])
        condition = "position < #{@ch_pos.position} AND position >= #{@before.position}"
        new_pos = @before.position
      else
        @after = current_site.banner_sites.find_by(id: params[:id_after])
        # In case it was moved from top to bottom
        if @ch_pos.position > @after.position
          condition = "position < #{@ch_pos.position} AND position > #{@after.position}"
          new_pos = @after.position + 1
          # In case it was moved from bottom to top
        else
          increment = -1
          condition = "position > #{@ch_pos.position} AND position <= #{@after.position}"
          new_pos = @after.position
        end
      end
      current_site.banner_sites.where(condition).update_all("position = position + (#{increment})")
      @ch_pos.update_attribute(:position, new_pos)
      head :ok
    end

    private

    def sort_column
      (Sticker::BannerSite.column_names + Sticker::Banner.column_names).include?(params[:sort]) ? params[:sort] : 'created_at'
    end

    def query_sort
      sort_field = if Sticker::BannerSite.column_names.include?(sort_column)
        "sticker_banner_sites.#{sort_column}"
      elsif Sticker::Banner.column_names.include?(sort_column)
        "sticker_banners.#{sort_column}"
      end
      params[:direction] = 'desc' if sort_column == 'created_at'
      "#{sort_field} #{sort_direction}"
    end

    def search_images
      @images = current_site.repositories
        .description_or_filename(params[:image_search])
        .content_file(%w(image flash))
        .page(params[:page]).per(current_site.per_page_default)
    end

    def banner_params
      params.require(:banner).permit(:repository_id, :size, :width, :height, :title, :text,
                                     :url, :target_id, :target_type, :publish, :new_tab, :shareable,
                                     :date_begin_at, :date_end_at,
                                     {banner_sites_attributes: [
                                        :id, :site_id, :category_list, :position
                                     ]}
                                    )
    end
  end
end

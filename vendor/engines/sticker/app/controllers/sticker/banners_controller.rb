module Sticker
  class BannersController < Sticker::ApplicationController
    before_action :check_current_site

    respond_to :html, :json

    def index
      respond_with do |format|
        format.html { redirect_to root_url(subdomain: current_site) }
        format.json {
          @banner_sites = get_banners
          render json: @banner_sites.map(&:banner).compact, root: 'banners', meta: { total: @banner_sites.total_count }
        }
      end
    end

    private

    def tag
      unescape_param(params[:tag]).mb_chars.downcase.to_s
    end

    def get_banners
      params[:direction] = 'desc' if params[:direction].blank?
      params[:page] = 1 if params[:page].blank?
      if params[:tag].present?
        result = current_site.banner_sites.published.available.includes(:categories, banner: [:repository, :site]).
          tagged_with(tag, any: true).
          order(sort_column + ' ' + sort_direction).
          page(params[:page]).per(params[:per_page])
      else
        result = current_site.banner_sites.published.available.includes(:categories, banner: [:repository, :site]).
          order(sort_column + ' ' + sort_direction).
          page(params[:page]).per(params[:per_page])
      end
      result
    end

    def sort_column
      params[:sort].present? ? params[:sort] : 'sticker_banners.id'
    end

    def check_current_site
      head 404 unless current_site
    end
  end
end

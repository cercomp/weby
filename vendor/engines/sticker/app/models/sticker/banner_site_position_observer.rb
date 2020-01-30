module Sticker
  class BannerSitePositionObserver < ActiveRecord::Observer
    observe 'sticker/banner_site'

    # UPDATE
    def before_save(banner_site)
      set_position(banner_site) if banner_site.new_record? || banner_site.position.nil?
    end

    def before_destroy(banner_site)
      leaving_position(banner_site)
    end

    private

    def leaving_position(banner_site)
      update_positions_top_of(banner_site)
      banner_site.position = 0
    end

    def update_positions_top_of(banner_site)
      Sticker::BannerSite
        .where(site_id: banner_site.site_id)
        .where("position > #{banner_site.position}")
        .update_all('position = position - 1') if banner_site.position.present?
    end

    def set_position(banner_site)
      max_pos = Sticker::BannerSite.where(site_id: banner_site.site_id).maximum(:position).to_i
      banner_site.position = max_pos + 1
    end
  end
end

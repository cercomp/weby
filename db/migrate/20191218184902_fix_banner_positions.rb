class FixBannerPositions < ActiveRecord::Migration
  def up
    Site.find_each do |site|
      banners = site.banner_sites.includes(:banner).published.order('sticker_banner_sites.position ASC, sticker_banner_sites.created_at DESC')
      (banners.size-1).downto(0).each.with_index do |pos, index|
        banners[index].update_column(:position, pos)
      end
    end
  end

  def down
    # nothing
  end
end

# This migration comes from sticker (originally 20200528175455)
class RemoveDateBeginAtFromStickerBannerSites < ActiveRecord::Migration[5.2]
  def change

    reversible do |dir|
      dir.up do
        Sticker::Banner.find_each do |banner|
          banner.update!(date_begin_at: banner.own_banner_site.date_begin_at, date_end_at: banner.own_banner_site.date_end_at)
        end
      end
      dir.down do
        #
      end
    end

    remove_column :sticker_banner_sites, :date_begin_at, :datetime
    remove_column :sticker_banner_sites, :date_end_at, :datetime
  end
end

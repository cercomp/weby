# This migration comes from sticker (originally 20140402120348)
class MigrateStickerBanners < ActiveRecord::Migration[4.2]
  def change
    return unless table_exists?(:banners)
    rename_table :banners, :sticker_banners
  end
end

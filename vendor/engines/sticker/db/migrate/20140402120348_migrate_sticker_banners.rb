class CreateStickerBanners < ActiveRecord::Migration
  def change
    rename_table :banners, :sticker_banners
  end
end

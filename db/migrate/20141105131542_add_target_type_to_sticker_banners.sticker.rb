# This migration comes from sticker (originally 20141105161842)
class AddTargetTypeToStickerBanners < ActiveRecord::Migration
  def up
    add_column :sticker_banners, :target_type, :string
    execute 'ALTER TABLE sticker_banners DROP CONSTRAINT banners_page_id_fk'
    rename_column :sticker_banners, :page_id, :target_id
    Sticker::Banner.where('target_id is not NULL AND target_id <> 0').update_all(target_type: 'Page')
  end

  def down
    remove_column :sticker_banners, :target_type, :string
    rename_column :sticker_banners, :target_id, :page_id
    add_foreign_key :sticker_banners, :pages
  end
end

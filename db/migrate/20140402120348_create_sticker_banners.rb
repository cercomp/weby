class CreateStickerBanners < ActiveRecord::Migration
  def change
    rename_table :banners, :sticker_banners     
    execute "update taggings set taggable_type='Sticker::Banner'  where taggable_type='Banner';"  
  end
end

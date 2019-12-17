# This migration comes from sticker (originally 20191217120844)
class AddShareableToBanners < ActiveRecord::Migration
  def change
    add_column :sticker_banners, :shareable, :boolean, default: false
  end
end

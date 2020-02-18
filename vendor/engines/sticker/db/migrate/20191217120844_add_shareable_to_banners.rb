class AddShareableToBanners < ActiveRecord::Migration
  def change
    add_column :sticker_banners, :shareable, :boolean, default: false
  end
end

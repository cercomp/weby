class AddPositionInBanners < ActiveRecord::Migration
  def self.up
    add_column :banners, :position, :integer
  end

  def self.down
    remove_column :banners, :position
  end
end

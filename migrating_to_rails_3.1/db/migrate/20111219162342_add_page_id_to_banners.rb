class AddPageIdToBanners < ActiveRecord::Migration
  def self.up
    add_column :banners, :page_id, :integer
  end

  def self.down
    remove_column :banners, :page_id
  end
end

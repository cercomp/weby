class RemoveCategoryColumnFromBanner < ActiveRecord::Migration
  def self.up
    remove_column :banners, :category
  end

  def self.down
    add_column :banners, :category, :string
  end
end

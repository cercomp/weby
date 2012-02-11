class AddPublishInPagesRemoveNxNBanners < ActiveRecord::Migration
  def self.up
	  add_column :pages, :publish, :boolean
	  add_column :banners, :publish, :boolean
    add_column :banners, :site_id, :integer
    remove_column :pages, :front
    add_column :pages, :front, :boolean
    drop_table :sites_banners
  end

  def self.down
	  remove_column :pages, :publish
    remove_column :banners, :publish
    remove_column :banners, :site_id
    remove_column :pages, :front
    add_column :pages, :front, :integer
    create_table :sites_banners
  end
end

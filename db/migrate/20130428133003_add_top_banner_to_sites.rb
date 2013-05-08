class AddTopBannerToSites < ActiveRecord::Migration
  def change
    add_column :sites, :top_banner_id, :integer
    add_column :sites, :top_banner_width, :integer
    add_column :sites, :top_banner_height, :integer
    
    add_index :sites, :top_banner_id
    
    add_foreign_key :sites, :repositories, column: :top_banner_id
  end
end

class CreateSitesPages < ActiveRecord::Migration
  def change
    create_table :sites_pages do |t|
      t.integer  :site_id
      t.integer  :page_id

      t.timestamps
    end
    
    add_index :sites_pages, :site_id
    add_index :sites_pages, :page_id
  end
end

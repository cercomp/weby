class CreateSitesPages < ActiveRecord::Migration
  def self.up
    create_table :sites_pages do |t|
      t.integer :site_id
      t.integer :page_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sites_pages
  end
end

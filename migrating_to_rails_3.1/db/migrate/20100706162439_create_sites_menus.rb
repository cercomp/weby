class CreateSitesMenus < ActiveRecord::Migration
  def self.up
    create_table :sites_menus do |t|
      t.integer :site_id
      t.integer :menu_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sites_menus
  end
end

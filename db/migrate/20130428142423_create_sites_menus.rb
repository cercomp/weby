class CreateSitesMenus < ActiveRecord::Migration
  def change
    create_table :sites_menus do |t|
      t.integer  :site_id
      t.integer  :menu_id
      t.integer  :parent_id,
        default: 0
      t.string   :category
      t.integer  :position

      t.timestamps
    end
    
    add_index :sites_menus, :site_id
    add_index :sites_menus, :menu_id

    add_foreign_key :sites_menus, :sites
    add_foreign_key :sites_menus, :menus
  end
end

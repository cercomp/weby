class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus do |t|
      t.integer  :site_id
      t.string   :name

      t.timestamps
    end
    
    add_index :menus, :site_id

    add_foreign_key :menus, :sites
  end
end

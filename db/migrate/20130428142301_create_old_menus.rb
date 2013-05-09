class CreateOldMenus < ActiveRecord::Migration
  def change
    create_table :old_menus do |t|
      t.string   :title
      t.string   :link
      t.integer  :page_id
      t.text     :description

      t.timestamps
    end
    
    add_index :old_menus, :page_id

    add_foreign_key :old_menus, :pages
  end
end

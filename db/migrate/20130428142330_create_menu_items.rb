class CreateMenuItems < ActiveRecord::Migration
  def change
    create_table :menu_items do |t|
      t.integer  :menu_id
      t.boolean  :separator,
        default: false
      t.integer  :target_id
      t.string   :target_type
      t.string   :url
      t.integer  :parent_id
      t.integer  :position,
        default: 0
      t.boolean  :new_tab,
        default: false

      t.timestamps
    end
    
    add_index :menu_items, :menu_id
    add_index :menu_items, :target_id
    add_index :menu_items, :parent_id

    add_foreign_key :menu_items, :menus
    add_foreign_key :menu_items, :menu_items, column: :parent_id
  end
end

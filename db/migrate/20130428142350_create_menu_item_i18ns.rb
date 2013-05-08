class CreateMenuItemI18ns < ActiveRecord::Migration
  def change
    create_table :menu_item_i18ns do |t|
      t.integer  :menu_item_id
      t.integer  :locale_id
      t.string   :title
      t.text     :description

      t.timestamps
    end
    
    add_index :menu_item_i18ns, :menu_item_id
    add_index :menu_item_i18ns, :locale_id

    add_foreign_key :menu_item_i18ns, :menu_items
    add_foreign_key :menu_item_i18ns, :locales
  end
end

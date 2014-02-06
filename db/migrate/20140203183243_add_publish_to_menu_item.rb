class AddPublishToMenuItem < ActiveRecord::Migration
  def change
    add_column :menu_items, :publish, :boolean, :default => true
  end
end

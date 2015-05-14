class AddSkinIdToTables < ActiveRecord::Migration
  def change
    add_column :components, :skin_id, :integer
    add_column :styles, :skin_id, :integer
    add_index :components, :skin_id
    add_index :styles, :skin_id
    remove_column :components, :site_id
    remove_column :styles, :site_id
  end
end

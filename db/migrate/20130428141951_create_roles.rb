class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string   :name
      t.string   :theme
      t.integer  :site_id

      t.timestamps
    end
    
    add_index :roles, :site_id

    add_foreign_key :roles, :sites
  end
end

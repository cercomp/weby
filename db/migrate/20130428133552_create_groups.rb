class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string   :name
      t.integer  :site_id
      t.text     :emails

      t.timestamps
    end
    
    add_index :groups, :site_id
    
    add_foreign_key :groups, :sites
  end
end

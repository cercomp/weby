class CreateMenus < ActiveRecord::Migration
  def self.up
    create_table :menus do |t|
      t.string :title
      t.integer :father_id
      t.string :position
      t.string :link

      t.timestamps
    end
  end

  def self.down
    drop_table :menus
  end
end

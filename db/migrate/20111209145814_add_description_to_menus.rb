class AddDescriptionToMenus < ActiveRecord::Migration
  def self.up
    add_column :menus, :description, :text
  end

  def self.down
    remove_column :menus, :description
  end
end

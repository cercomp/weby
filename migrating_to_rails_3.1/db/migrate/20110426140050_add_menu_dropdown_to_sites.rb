class AddMenuDropdownToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :menu_dropdown, :boolean
  end

  def self.down
    remove_column :sites, :menu_dropdown
  end
end

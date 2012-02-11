class AddMenusPageId < ActiveRecord::Migration
  def self.up
    add_column :menus, :page_id, :integer
  end

  def self.down
    remove_column :menus, :page_id
  end
end

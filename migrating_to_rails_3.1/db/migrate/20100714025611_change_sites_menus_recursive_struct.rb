class ChangeSitesMenusRecursiveStruct < ActiveRecord::Migration
  def self.up
    add_column(:sites_menus, :parent_id, :integer, :after => :menu_id)
    add_column(:sites_menus, :position, :string, :after => :parent_id)
    remove_column(:menus, :father_id)
    remove_column(:menus, :position)
  end

  def self.down
    remove_column(:sites_menus, :parent_id)
    remove_column(:sites_menus, :position)
    add_column(:menus, :father_id, :integer)
    add_column(:menus, :position, :string)
  end
end

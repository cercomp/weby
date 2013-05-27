class AddPermissionsToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :permissions, :text
  end
end

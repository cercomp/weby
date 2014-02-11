class DropFieldThemeFromRoles < ActiveRecord::Migration
  def change
    remove_column :roles, :theme
  end
end

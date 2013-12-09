class AddDeleted < ActiveRecord::Migration
  def change
    add_column :styles, :deleted, :boolean, default: false
    add_column :roles, :deleted, :boolean, default: false
    add_column :repositories, :deleted, :boolean, default: false
    add_column :pages, :deleted, :boolean, default: false
    add_column :menus, :deleted, :boolean, default: false
    add_column :site_components, :deleted, :boolean, default: false
    add_column :banners, :deleted, :boolean, default: false
    add_column :feedback_groups, :deleted, :boolean, default: false
  end
end

class AddCategoriesToModels < ActiveRecord::Migration
  def self.up
    add_column :pages, :category, :string
    add_column :banners, :category, :string
    rename_column :sites_menus, :side, :category
  end

  def self.down
    remove_column :pages, :category
    remove_column :banners, :category
    rename_column :sites_menus, :category, :side
  end
end

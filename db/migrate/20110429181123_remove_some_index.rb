class RemoveSomeIndex < ActiveRecord::Migration
  def self.up
    remove_index :pages, :column => [:site_id, :repository_id]
    remove_index :sites_pages, :column => [:site_id, :page_id]
    remove_index :sites_menus, :column => [:site_id, :menu_id]
    remove_index :pages_repositories, :column => [:page_id, :repository_id]
  end
  
  def self.down
    add_index :pages, [:site_id, :repository_id], :unique => true
    add_index :sites_pages, [:site_id, :page_id], :unique => true
    add_index :sites_menus, [:site_id, :menu_id], :unique => true
    add_index :pages_repositories, [:page_id, :repository_id], :unique => true
  end
end

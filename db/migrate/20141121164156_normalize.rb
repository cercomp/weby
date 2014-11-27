class Normalize < ActiveRecord::Migration
  def change
    rename_table :extension_sites, :extensions
    rename_table :site_components, :components
    drop_table :groups_users
    drop_table :old_menus
    drop_table :sites_menus
    drop_table :sites_pages
  end
end

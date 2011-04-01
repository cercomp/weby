class AddAuthorToSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :view_desc_pages, :boolean, :default => false
  end

  def self.down
    remove_column :sites, :view_desc_pages
  end
end

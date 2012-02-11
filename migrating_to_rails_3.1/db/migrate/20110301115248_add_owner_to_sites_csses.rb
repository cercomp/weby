class AddOwnerToSitesCsses < ActiveRecord::Migration
  def self.up
    add_column :sites_csses, :owner, :boolean
  end

  def self.down
    remove_column :sites_csses, :owner
  end
end

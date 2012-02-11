class AddPerPageDefaultToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :per_page_default, :integer, :default => 25
  end

  def self.down
    remove_column :sites, :per_page_default
  end
end

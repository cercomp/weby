class AddCoverSizeToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :cover_size, :integer, :default => 5
  end

  def self.down
    remove_column :sites, :cover_size
  end
end

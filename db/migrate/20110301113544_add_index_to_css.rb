class AddIndexToCss < ActiveRecord::Migration
  def self.up
     add_index :sites_csses, [:site_id, :css_id], :unique => true
  end

  def self.down
    remove_index :sites_csses, :column => [:site_id, :css_id]
  end
end

class CreateSitesCsses < ActiveRecord::Migration
  def self.up
    create_table :sites_csses, :id => false do |t|
      t.integer :site_id, :null => false
      t.integer :css_id, :null => false
      t.boolean :publish

      t.timestamps
    end
  end

  def self.down
    drop_table :sites_csses
  end
end

class Test < ActiveRecord::Migration
  def self.up
    remove_index :sites_csses, :column => [:site_id, :css_id]
    drop_table :sites_csses

    create_table :sites_csses do |t|
      t.integer :site_id, :null => false
      t.integer :css_id, :null => false
      t.boolean :publish
      t.boolean :owner

      t.timestamps
    end
  end

  def self.down
    drop_table :sites_csses

    create_table :sites_csses, :id => false do |t|
      t.integer :site_id, :null => false
      t.integer :css_id, :null => false
      t.boolean :publish
      t.boolean :owner

      t.timestamps
    end

    add_index :sites_csses, [:site_id, :css_id], :unique => true
  end
end

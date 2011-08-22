class CreateLocalesSites < ActiveRecord::Migration
  def self.up
    create_table :locales_sites, :id => false do |t|
      t.integer :locale_id, :null => false
      t.integer :site_id, :null => false
    end

    add_index :locales_sites, [:locale_id, :site_id], :unique => true
  end

  def self.down
    drop_table :locales_sites
  end
end

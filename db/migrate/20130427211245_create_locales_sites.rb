class CreateLocalesSites < ActiveRecord::Migration
  def change
    create_table :locales_sites, id: false do |t|
      t.integer  :locale_id
      t.integer  :site_id
    end
    
    add_index :locales_sites, :locale_id
    add_index :locales_sites, :site_id
    
    add_foreign_key :locales_sites, :locales
    add_foreign_key :locales_sites, :sites
  end
end

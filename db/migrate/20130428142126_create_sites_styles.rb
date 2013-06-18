class CreateSitesStyles < ActiveRecord::Migration
  def change
    create_table :sites_styles do |t|
      t.integer  :site_id
      t.integer  :style_id
      t.boolean  :publish,
        default: true

      t.timestamps
    end
    
    add_index :sites_styles, :site_id
    add_index :sites_styles, :style_id

    add_foreign_key :sites_styles, :sites
    add_foreign_key :sites_styles, :styles
  end
end

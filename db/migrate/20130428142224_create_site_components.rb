class CreateSiteComponents < ActiveRecord::Migration
  def change
    create_table :site_components do |t|
      t.integer  :site_id
      t.string   :place_holder
      t.text     :settings
      t.string   :name
      t.integer  :position
      t.boolean  :publish,
        default: true
      t.integer  :visibility,
        default: 0
      t.string   :alias

      t.timestamps
    end
    
    add_index :site_components, :site_id

    add_foreign_key :site_components, :sites
  end
end

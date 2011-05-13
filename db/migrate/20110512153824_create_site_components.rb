class CreateSiteComponents < ActiveRecord::Migration
  def self.up
    create_table :site_components do |t|
      t.references :site
      t.string :place_holder
      t.text :settings
      t.string :component

      t.timestamps
    end
  end

  def self.down
    drop_table :site_components
  end
end

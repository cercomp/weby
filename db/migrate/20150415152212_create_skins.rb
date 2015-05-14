class CreateSkins < ActiveRecord::Migration
  def change
    create_table :skins do |t|
      t.references :site, index: true
      t.string :theme
      t.string :name
      t.text :components
      t.text :layout
      t.text :variables
      t.text :css
      t.boolean :active, default: false

      t.timestamps
    end
  end
end

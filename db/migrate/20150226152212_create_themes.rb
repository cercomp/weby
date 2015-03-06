class CreateThemes < ActiveRecord::Migration
  def change
    create_table :themes do |t|
      t.references :site, index: true
      t.string :name
      t.string :base
      t.text :components
      t.text :layout
      t.text :variables
      t.text :css

      t.timestamps
    end
  end
end

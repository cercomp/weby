class CreateCsses < ActiveRecord::Migration
  def self.up
    create_table :csses do |t|
      t.string :name
      t.text :css
      t.integer :site_id
      t.boolean :publish

      t.timestamps
    end
  end

  def self.down
    drop_table :csses
  end
end

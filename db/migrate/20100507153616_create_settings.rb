class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.string :name
      t.string :value
      t.text :description
      t.string :group
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :settings
  end
end

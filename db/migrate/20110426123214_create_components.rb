class CreateComponents < ActiveRecord::Migration
  def self.up
    create_table :components do |t|
      t.string :name
      t.text :body
      t.boolean :enable
      t.references :site

      t.timestamps
    end
  end

  def self.down
    drop_table :components
  end
end

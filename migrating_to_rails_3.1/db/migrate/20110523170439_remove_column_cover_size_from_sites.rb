class RemoveColumnCoverSizeFromSites < ActiveRecord::Migration
  def self.up
    remove_column :sites, :cover_size
    drop_table :components
  end

  def self.down
    add_column :sites, :cover_size, :integer, :default => 5
    create_table :components do |t|
      t.string :name
      t.text :body
      t.boolean :enable
      t.references :site

      t.timestamps
    end
  end
end

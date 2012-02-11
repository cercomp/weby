class RemoveColumnCsses < ActiveRecord::Migration
  def self.up
	  remove_column :csses, :site_id
	  remove_column :csses, :publish
  end

  def self.down
	  add_column :csses, :site_id, :integer
	  add_column :csses, :publish, :boolean
  end
end

class ChangeFooterType < ActiveRecord::Migration
  def self.up
  
	remove_collumn :sites, :footer
	add_column :sites, :footer, :text
	
	end

  def self.down
	
	remove_column :sites, :footer
	add_column :sites, :footer, :string

  end
end

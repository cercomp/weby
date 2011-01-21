class AddCoverToSites < ActiveRecord::Migration
  def self.up
		
		add_column :sites, :cover_id, :integer 

	end

  def self.down
  		
	remove_column :sites, :cover_id
		
	end
end

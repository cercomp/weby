class AddPagesAndRepositories < ActiveRecord::Migration
  def self.up
		create_table :pages_repositories, :id => false do |t|
			t.references :page, :repository
		end	
	end

  def self.down
		drop_table :pages_repositories	
	end
end

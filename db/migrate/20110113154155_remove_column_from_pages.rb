class RemoveColumnFromPages < ActiveRecord::Migration
  def self.up
		
	remove_column :pages, :date_pub

	end

  def self.down

	add_column :pages, :date_pub, :date

  end
end

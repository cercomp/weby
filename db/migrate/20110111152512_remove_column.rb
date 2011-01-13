class RemoveColumn < ActiveRecord::Migration
  def self.up

	remove_column :pages, :front_time
	
	end

  def self.down

	add_column :pages, :front_time, :date

  end
end

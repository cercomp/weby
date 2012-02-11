class AddTimestampToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.timestamps
    end
  end

  def self.down
    #remove_column :users, :created_at
    #remove_column :users, :updated_at
    remove_timestamps(:users)
  end
end

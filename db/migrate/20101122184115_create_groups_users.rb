class CreateGroupsUsers < ActiveRecord::Migration
  def self.up
    crate_table :groups_users, :id => false do |t|
      t.integer :group_id, :null => false
      t.integer :user_id, :null => false
    end

    add_index :groups_users, [:group_id, :user_id], :unique => true
  end

  def self.down
    remove_index :groups_users, :column => [:group_id, :user_id]
    drop_table :groups_users
  end
end

class CreateGroupsUsers < ActiveRecord::Migration
  def change
    create_table :groups_users, id: false do |t|
      t.integer  :group_id
      t.integer  :user_id
    end
    
    add_index :groups_users, :group_id
    add_index :groups_users, :user_id
    
    add_foreign_key :groups_users, :groups
    add_foreign_key :groups_users, :users
  end
end

class CreateRolesUsers < ActiveRecord::Migration
  def change
    create_table :roles_users, id: false do |t|
      t.integer  :role_id
      t.integer  :user_id
    end
    
    add_index :roles_users, :role_id
    add_index :roles_users, :user_id

    add_foreign_key :roles_users, :roles
    add_foreign_key :roles_users, :users
  end
end

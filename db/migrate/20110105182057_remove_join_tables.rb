class RemoveJoinTables < ActiveRecord::Migration
  def self.up
    drop_table :roles_users

    drop_table :sites_users
  end

  def self.down
    create_table :roles_user do |t|
      t.integer :user_id
      t.integer :role_id

      t;timestamps
    end

    create_table :sites_users do |t|
      t.integer :site_id
      t.integer :user_id

      t.timestamps
    end
  end
end

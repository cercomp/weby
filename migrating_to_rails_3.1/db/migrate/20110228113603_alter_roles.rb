class AlterRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :site_id, :integer

    drop_table :user_site_enroleds
  end

  def self.down
    remove_column :roles, :site

    create_table :user_site_enroleds do |t|
      t.integer :user_id
      t.integer :site_id
      t.integer :role_id

      t.timestamps
    end
  end
end

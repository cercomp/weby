class CreateRightsRoles < ActiveRecord::Migration
  def change
    create_table :rights_roles do |t|
      t.integer  :right_id
      t.integer  :role_id

      t.timestamps
    end
    
    add_index :rights_roles, :right_id
    add_index :rights_roles, :role_id

    add_foreign_key :rights_roles, :rights
    add_foreign_key :rights_roles, :roles
  end
end

class DropRights < ActiveRecord::Migration
  def change
    drop_table :rights_roles
    drop_table :rights
  end
end

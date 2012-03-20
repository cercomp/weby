class AddOwnerToStyles < ActiveRecord::Migration
  def change
    add_column :styles, :owner_id, :integer
  end
end

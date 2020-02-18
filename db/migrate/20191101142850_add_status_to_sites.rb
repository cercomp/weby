class AddStatusToSites < ActiveRecord::Migration
  def change
    add_column :sites, :status, :string, default: 'active'
    add_index :sites, :status
  end
end

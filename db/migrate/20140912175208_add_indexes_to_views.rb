class AddIndexesToViews < ActiveRecord::Migration
  def change
    add_index :views, :created_at
    add_index :views, [:created_at, :site_id]
    add_index :views, :session_hash
    add_index :views, :ip_address
  end
end

class AddPreferencesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :preferences, :jsonb, default: {}
  end
end

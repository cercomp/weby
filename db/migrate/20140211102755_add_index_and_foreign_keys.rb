class AddIndexAndForeignKeys < ActiveRecord::Migration
  def change
    add_index :notifications, :user_id

    add_foreign_key :notifications, :users

    add_index :activity_records, :user_id
    add_index :activity_records, :site_id

    add_foreign_key :activity_records, :users
    add_foreign_key :activity_records, :sites

    add_index :groupings_sites, :grouping_id
    add_index :groupings_sites, :site_id

    add_foreign_key :groupings_sites, :groupings
    add_foreign_key :groupings_sites, :sites
  end
end

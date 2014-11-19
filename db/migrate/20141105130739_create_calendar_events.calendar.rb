# This migration comes from calendar (originally 20140801145827)
class CreateCalendarEvents < ActiveRecord::Migration
  def change
    create_table :calendar_events do |t|
      t.integer  :site_id
      t.integer  :repository_id
      t.integer  :user_id
      t.datetime :begin_at
      t.datetime :end_at
      t.string   :email
      t.string   :url
      t.string   :kind
      t.datetime :deleted_at, default: nil
      t.integer  :view_count, default: 0

      t.timestamps
    end

    add_index :calendar_events, :user_id
    add_index :calendar_events, :site_id
    add_index :calendar_events, :repository_id

    add_foreign_key :calendar_events, :users
    add_foreign_key :calendar_events, :sites
    add_foreign_key :calendar_events, :repositories
  end
end

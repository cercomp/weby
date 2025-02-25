# db/migrate/20241215204034_create_calendar_event_sites.calendar.rb
class CreateCalendarEventSites < ActiveRecord::Migration[4.2]
  def up
    create_table :calendar_event_sites do |t|
      t.references :calendar_event
      t.references :site
      t.integer :position
      t.boolean :front, default: false
      t.timestamps
    end

    add_index :calendar_event_sites, :calendar_event_id
    add_index :calendar_event_sites, :site_id
    add_index :calendar_event_sites, [:calendar_event_id, :site_id], unique: true

    execute <<-SQL
      INSERT INTO calendar_event_sites (calendar_event_id, site_id, created_at, updated_at)
      SELECT id, site_id, created_at, updated_at
      FROM calendar_events;
    SQL

    execute <<-SQL
      UPDATE taggings 
      SET taggable_type = 'Calendar::EventSite', 
          taggable_id = (select id from calendar_event_sites where taggable_id = calendar_event_sites.calendar_event_id)
      WHERE taggable_type = 'Calendar::Event';
    SQL
  end

  def down
    drop_table :calendar_event_sites
  end
end
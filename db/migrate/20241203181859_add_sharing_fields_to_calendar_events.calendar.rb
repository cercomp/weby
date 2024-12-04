# This migration comes from calendar (originally 202412031500)
class AddSharingFieldsToCalendarEvents < ActiveRecord::Migration[4.2]
  def change
    unless column_exists?(:calendar_events, :parent_event_id)
      add_column :calendar_events, :parent_event_id, :integer
      add_index :calendar_events, :parent_event_id
    end

    unless column_exists?(:calendar_events, :shared)
      add_column :calendar_events, :shared, :boolean, default: false
      add_index :calendar_events, :shared
    end

    unless column_exists?(:calendar_events, :sync_fields)
      add_column :calendar_events, :sync_fields, :text, default: ''
    end

    unless foreign_key_exists?(:calendar_events, :calendar_events)
      add_foreign_key :calendar_events, :calendar_events, 
                      column: :parent_event_id,
                      on_delete: :cascade
    end

    unless column_exists?(:calendar_event_i18ns, :sync_with_parent)
      add_column :calendar_event_i18ns, :sync_with_parent, :boolean, default: true
    end
  end
end
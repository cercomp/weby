class AddSharingFieldsToCalendarEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :calendar_events, :parent_event_id, :integer
    add_column :calendar_events, :shared, :boolean, default: false

    add_index :calendar_events, :parent_event_id
    add_index :calendar_events, :shared

    add_foreign_key :calendar_events, :calendar_events, 
                    column: :parent_event_id,
                    on_delete: :cascade
  end
end
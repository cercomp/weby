# This migration comes from feedback (originally 20130414121731)
class MigrateFeedbackExtension < ActiveRecord::Migration[4.2]
  def up
    return unless table_exists?(:groups)
    
    rename_table :groups, :feedback_groups
    rename_table :feedbacks, :feedback_messages if table_exists?(:feedbacks)
    rename_table :feedbacks_groups, :feedback_messages_groups if table_exists?(:feedbacks_groups)

    if table_exists?(:feedback_messages_groups)
      rename_column :feedback_messages_groups, :feedback_id, :message_id
    end
  end

  def down
    return unless table_exists?(:feedback_groups)
    
    rename_column :feedback_messages_groups, :message_id, :feedback_id if table_exists?(:feedback_messages_groups)

    rename_table :feedback_messages_groups, :feedbacks_groups if table_exists?(:feedback_messages_groups)
    rename_table :feedback_messages, :feedbacks if table_exists?(:feedback_messages)
    rename_table :feedback_groups, :groups
  end
end
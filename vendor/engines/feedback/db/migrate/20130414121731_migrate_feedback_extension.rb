class MigrateFeedbackExtension < ActiveRecord::Migration
  def up
    rename_table :groups, :feedback_groups
    rename_table :feedbacks, :feedback_messages
    rename_table :feedbacks_groups, :feedback_messages_groups

    rename_column :feedback_messages_groups, :feedback_id, :message_id
  end

  def down
    rename_column :feedback_messages_groups, :message_id, :feedback_id

    rename_table :feedback_messages_groups, :feedbacks_groups
    rename_table :feedback_messages, :feedbacks
    rename_table :feedback_groups, :groups
  end
end

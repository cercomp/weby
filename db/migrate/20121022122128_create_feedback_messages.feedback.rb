# This migration comes from feedback (originally 20121022121731)
class CreateFeedbackMessages < ActiveRecord::Migration
  def up
    create_table :feedback_messages do |t|
      t.string :name
      t.string :email
      t.string :subject
      t.text :message
      t.references :site
      t.string :to

      t.timestamps
    end

    rename_table  :feedbacks_groups, :groups_messages
    rename_column :groups_messages, :feedback_id, :message_id
    add_index     :feedback_messages, :site_id
  end

  def down
    rename_column :groups_messages, :message_id, :feedback_id
    rename_table  :groups_messages, :feedbacks_groups

    drop_table   :feedback_messages
  end
end

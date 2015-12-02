class AddReadStatusMsgToFeedbackMessages < ActiveRecord::Migration
  def change
    add_column :feedback_messages, :read_status, :boolean, :default => false
  end
end

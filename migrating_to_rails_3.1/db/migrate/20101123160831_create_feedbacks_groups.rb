class CreateFeedbacksGroups < ActiveRecord::Migration
  def self.up
    create_table :feedbacks_groups, :id => false do |t|
      t.integer :feedback_id, :null => false
      t.integer :group_id, :null => false
    end

    add_index :feedbacks_groups, [:feedback_id, :group_id], :unique => true
  end

  def self.down
    remove_index :feedbacks_groups, :column => [:feedback_id, :group_id]
    drop_table :feedbacks_groups
  end

end

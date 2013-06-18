class CreateFeedbacksGroups < ActiveRecord::Migration
  def change
    create_table :feedbacks_groups, id: false do |t|
      t.integer  :feedback_id
      t.integer  :group_id
    end
    
    add_index :feedbacks_groups, :feedback_id
    add_index :feedbacks_groups, :group_id

    add_foreign_key :feedbacks_groups, :feedbacks
    add_foreign_key :feedbacks_groups, :groups
  end
end

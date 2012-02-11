class CreateFeedbackUsersGroups < ActiveRecord::Migration
  def self.up
    create_table :feedback_users_groups do |t|
      t.integer :talk_id
      t.integer :user_id
      t.integer :group_id

      t.timestamps
    end
  end

  def self.down
    drop_table :feedback_users_groups
  end
end

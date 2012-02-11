class DropTableFeedbackUsersGroups < ActiveRecord::Migration
  def self.up
    drop_table :feedback_users_groups
  end

  def self.down
    create_table :feedback_users_groups do |t|
      t.integer :talk_id
      t.integer :user_id
      t.integer :group_id

      t.timestamps
    end
  end
end

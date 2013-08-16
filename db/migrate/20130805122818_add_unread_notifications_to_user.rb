class AddUnreadNotificationsToUser < ActiveRecord::Migration
  def change
    add_column :users, :unread_notifications, :string, default: "$"
  end
end

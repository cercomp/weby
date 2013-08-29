class AddUnreadNotificationsToUser < ActiveRecord::Migration
  def change
    add_column :users, :unread_notifications, :string
  end
end

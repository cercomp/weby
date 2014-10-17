class ChangeUserAgentOfViews < ActiveRecord::Migration
  def up
    change_column :views, :user_agent, :text
  end
  def down
    change_column :views, :user_agent, :string
  end
end

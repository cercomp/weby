class ChangeUserAgentOfViews < ActiveRecord::Migration
  def up
    change_column :views, :user_agent, :text
    change_column :views, :referer, :text
    change_column :views, :query_string, :text
  end
  def down
    change_column :views, :user_agent, :string
    change_column :views, :referer, :string
    change_column :views, :query_string, :string
  end
end

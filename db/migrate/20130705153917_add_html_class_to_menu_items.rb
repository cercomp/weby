class AddHtmlClassToMenuItems < ActiveRecord::Migration
  def change
    add_column :menu_items, :html_class, :string
  end
end

class ChangeSitesAddNameDescriptionUrlRemoveUserMenuPage < ActiveRecord::Migration
  def self.up
    remove_column :sites, :user_id
    remove_column :sites, :menu_id
    remove_column :sites, :page_id
    add_column :sites, :url, :string
    add_column :sites, :description, :text
  end

  def self.down
    add_column :sites, :user_id, :integer
    add_column :sites, :menu_id, :integer
    add_column :sites, :page_id, :integer
    remove_column :sites, :url
    remove_column :sites, :description
  end
end

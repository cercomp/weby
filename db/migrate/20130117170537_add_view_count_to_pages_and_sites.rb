class AddViewCountToPagesAndSites < ActiveRecord::Migration
  def change
    add_column :pages, :view_count, :integer, default: 0
    add_column :sites, :view_count, :integer, default: 0
    add_column :banners, :click_count, :integer, default: 0
  end
end

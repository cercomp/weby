class AddHeadHtmlToSites < ActiveRecord::Migration
  def change
    add_column :sites, :head_html, :text
  end
end

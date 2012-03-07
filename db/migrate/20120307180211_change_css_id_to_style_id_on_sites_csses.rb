class ChangeCssIdToStyleIdOnSitesCsses < ActiveRecord::Migration
  def change
    rename_column :sites_csses, :css_id, :style_id
  end
end

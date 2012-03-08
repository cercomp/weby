class RenameSitesCssesToSitesStyles < ActiveRecord::Migration
  def change
    rename_table :sites_csses, :sites_styles
  end
end

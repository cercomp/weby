class AddRestrictThemeToSites < ActiveRecord::Migration
  def change
    add_column :sites, :restrict_theme, :boolean, default: false
  end
end

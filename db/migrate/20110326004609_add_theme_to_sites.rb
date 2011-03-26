class AddThemeToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :theme, :string
  end

  def self.down
    remove_column :sites, :theme
  end
end

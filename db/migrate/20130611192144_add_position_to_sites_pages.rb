class AddPositionToSitesPages < ActiveRecord::Migration
  def change
    add_column :sites_pages, :position, :integer
  end
end

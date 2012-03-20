class RemoveOwnerFromSitesStyles < ActiveRecord::Migration
  def up
    remove_column :sites_styles, :owner
      end

  def down
    add_column :sites_styles, :owner, :boolean
  end
end

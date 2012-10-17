class AddVisibilityToSiteComponents < ActiveRecord::Migration
  def change
    add_column :site_components, :visibility, :integer, default: 0
  end
end

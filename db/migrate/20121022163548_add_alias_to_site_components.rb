class AddAliasToSiteComponents < ActiveRecord::Migration
  def change
    add_column :site_components, :alias, :string
  end
end

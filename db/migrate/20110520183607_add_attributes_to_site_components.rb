class AddAttributesToSiteComponents < ActiveRecord::Migration
  def self.up
    add_column :site_components, :position, :integer
    add_column :site_components, :publish, :boolean
  end

  def self.down
    remove_column :site_components, :publish
    remove_column :site_components, :position
  end
end

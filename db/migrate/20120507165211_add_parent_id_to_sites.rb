class AddParentIdToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :title, :string, limit: 50
    add_column :sites, :parent_id, :integer

    Site.all.each do |site|
      site.update_attribute(:title, site.name.titleize)
    end
  end

  def self.down
    remove_column :sites, :title
    remove_column :sites, :parent_id
  end
end

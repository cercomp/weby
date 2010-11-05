class ChangeSitesMenusParentIdZeroPositionNil < ActiveRecord::Migration
  def self.up
    change_column :sites_menus, :parent_id, :integer, :default => 0
    #change_column :sites_menus, :postion, :integer, :null => true
    say_with_time "Upgrading sites_menus, defining 0 to parent_id equal nil..." do
      SitesMenu.find(:all).each do |p|
        p.update_attribute(:parent_id, "0") if p.parent_id.nil?
      end
    end
  end

  def self.down
  end
end

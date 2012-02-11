class AddSideInMenus < ActiveRecord::Migration
  def self.up
    add_column :sites_menus, :side, :string
    say_with_time "Upgrading menus..." do
      SitesMenu.find(:all).each do |p|
        p.update_attribute :side, p.position
      end
    end
    remove_column :sites_menus, :position
    add_column :sites_menus, :position, :integer
  end

  def self.down
    remove_column :sites_menus, :side
    add_column :sites_menus, :position, :string
  end
end

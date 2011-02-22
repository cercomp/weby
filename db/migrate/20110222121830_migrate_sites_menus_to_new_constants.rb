class MigrateSitesMenusToNewConstants < ActiveRecord::Migration
  def self.up
    say_with_time "Upgrading sites_menus, defining new constants to field side..." do
      SitesMenu.find(:all).each do |p|
        if p.side == 'top'
          p.update_attribute(:side, "main")
        elsif p.side == 'bottom'
          p.update_attribute(:side, "base")
        elsif p.side == 'left'
          p.update_attribute(:side, "secondary")
        elsif p.side == 'right'
          p.update_attribute(:side, "auxiliary")
        end
      end
    end
  end

  def self.down
    say_with_time "Rerting sites_menus, defining old constants to field side..." do
      SitesMenu.find(:all).each do |p|
        if p.side == 'main'
          p.update_attribute(:side, "top")
        elsif p.side == 'base'
          p.update_attribute(:side, "bottom")
        elsif p.side == 'secondary'
          p.update_attribute(:side, "left")
        elsif p.side == 'auxiliary'
          p.update_attribute(:side, "right")
        end
      end
    end
  end
end

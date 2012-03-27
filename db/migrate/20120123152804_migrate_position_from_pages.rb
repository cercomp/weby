class MigratePositionFromPages < ActiveRecord::Migration
  def self.up
    #Seta a position das páginas que não são capa pra 0 e inverte a ordem da position das capas
    Page.joins(:sites).where(:front=>true).except(:order).order('sites.id asc, position desc, sites_pages.id asc').readonly(false).group_by{|page|page.sites[0].id}.each do |site, pages|
      index = 1
      pages.each do |page|
        page.update_attribute(:position, index)
        index = index+1
      end
    end
    Page.update_all({:position=>0},{:front=>false})
  end

  def self.down
  end
end

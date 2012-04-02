class MigratePositionFromPages < ActiveRecord::Migration
  def self.change
    #Seta a position das páginas que não são capa pra 0 e inverte a ordem da position das capas
    Page.where(:front=>true).except(:order).order('site_id asc, position desc, id asc').readonly(false).group_by{|page|page.site_id}.each do |site, pages|
      index = 1
      pages.each do |page|
        page.update_attribute(:position, index)
        index = index+1
      end
    end
    Page.update_all({:position=>0},{:front=>false})
  end
  
end

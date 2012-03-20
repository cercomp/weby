class MigrateOwnerFromSitesStylesToStyles < ActiveRecord::Migration
  def up
    SitesStyle.all.each do |site_style|
      if site_style.owner == true
        if site_style.style.owner_id.nil?
          site_style.style.owner_id = site_style.site.id
          site_style.style.save
        else 
          style = site_style.style.dup
          style.owner_id = site_style.site.id
          site_style.style = style
          site_style.style.save
        end
      end
      site_style.owner = nil
      site_style.save
    end
  end

  def down
    SitesStyle.all.each do |site_style|
      if site_style.style.owner_id == site_style.site_id
        site_style.style.owner_id = nil
        site_style.style.save
        site_style.owner = true
        site_style.save
      else 
        site_style.owner = false
        site_style.save
      end
    end
  end
end

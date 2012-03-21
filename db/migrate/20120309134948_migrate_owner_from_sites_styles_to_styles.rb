class MigrateOwnerFromSitesStylesToStyles < ActiveRecord::Migration
  def up
    SitesStyle.all.each do |site_style|
      if site_style.owner == true
        style = Style.find(site_style.style_id)
        if style.owner_id.nil?
          style.update_attributes(owner_id: site_style.site_id)
        else 
          newstyle = Style.new(name: style.name, css: style.css, owner_id: site_style.site_id)
          newstyle.save
          site_style.update_attributes(style_id: newstyle.id)
        end
      end
    end
    Style.where(owner_id: nil).each do |style|
      style.delete
    end
  end

  def down
    Style.all.each do |style|
      site_style = SitesStyle.where(style_id: style.id, site_id: style.owner_id).first
      site_style.update_attributes(owner: true)
      style.update_attributes(owner_id: nil)
    end
    SitesStyle.where(owner: nil).each do |site_style|
      site_style.update_attributes(owner: false)
    end
  end
end

class MigrateOwnerFromSitesStylesToStyles < ActiveRecord::Migration
  def up
    SitesStyle.where(owner: true).each do |site_style|
      site_style.style.owner_id = site_style.site.id
      site_style.style.save
    end
  end

  def down
    Style.where('owner_id IS NOT NULL').each do |style|
      rel = style.sites_styles.where(site_id: style.owner_id).first
      rel.owner = true
      rel.save
    end
    
    SitesStyle.where('owner IS NULL').each do |sites_style|
      sites_style.owner = false
      sites_style.save
    end
  end
end

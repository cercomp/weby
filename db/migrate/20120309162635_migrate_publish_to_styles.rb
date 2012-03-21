class MigratePublishToStyles < ActiveRecord::Migration
  def up
    Style.all.each do |style|
      site_style = SitesStyle.where(site_id: style.owner_id, style_id: style.id).first
      publish = style.sites_styles.where(site_id: style.owner_id).first.publish
      style.update_attributes(publish: site_style.publish)
      site_style.delete
    end
  end

  def down
    Style.all.each do |style|
      site_style = SitesStyle.new(site_id: style.owner_id, style_id: style.id, publish: style.publish)
      site_style.save
    end
  end
end

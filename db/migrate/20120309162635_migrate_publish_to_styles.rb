class MigratePublishToStyles < ActiveRecord::Migration
  def up
    Style.where(publish: nil).each do |style|
      style.publish = style.sites_styles.where(site_id: style.owner_id).first.publish
      style.save
      style.sites_styles.where(site_id: style.owner_id).first.delete
    end
  end

  def down
    Style.where('publish is not null').each do |style|
      style.sites_styles.build(:site_id => style.owner_id, :publish => style.publish)
      style.publish = nil
      style.save
    end
  end
end

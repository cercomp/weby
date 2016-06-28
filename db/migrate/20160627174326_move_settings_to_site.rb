class MoveSettingsToSite < ActiveRecord::Migration
  def up
    Extension.includes(:site).where(name: 'journal').each do |ext|
      settings = ext.settings.get_all

      if settings['social_share_pos'].present?
        ext.site.settings['news.social_share_pos'] = settings['social_share_pos']
        ext.settings.destroy :social_share_pos
      end

      if settings['social_share_networks_'].present?
        ext.site.settings['news.social_share_networks'] = settings['social_share_networks_']
        ext.settings.destroy :social_share_networks_
      end
    end
  end

  def down
    Extension.includes(:site).where(name: 'journal').each do |ext|
      site = ext.site
      settings = site.settings.get_all

      if settings['news.social_share_pos'].present?
        ext.settings.social_share_pos = settings['news.social_share_pos']
        site.settings.destroy 'news.social_share_pos'
      end

      if settings['news.social_share_networks'].present?
        ext.settings.social_share_networks_ = settings['news.social_share_networks']
        site.settings.destroy 'news.social_share_networks'
      end
    end
  end
end

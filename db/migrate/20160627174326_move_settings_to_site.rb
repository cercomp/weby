class MoveSettingsToSite < ActiveRecord::Migration
  def up
    Extension.includes(:site).where(name: 'journal').each do |ext|
      settings = ext.settings

      if settings['social_share_pos'].present?
        ext.site.settings['news.social_share_pos'] = settings['social_share_pos']
        #ext.settings.destroy :social_share_pos
      end

      if settings['social_share_networks_'].present?
        ext.site.settings['news.social_share_networks'] = settings['social_share_networks_']
        #ext.settings.destroy :social_share_networks_
      end
      if settings['facebook_comments_'].present?
        ext.site.settings['news.facebook_comments'] = settings['facebook_comments_']
        #ext.settings.destroy :facebook_comments_
      end
      ext.site.save
    end
  end

  def down
    Extension.includes(:site).where(name: 'journal').each do |ext|
      site = ext.site
      settings = site.settings

      if settings['news.social_share_pos'].present?
        ext.settings['social_share_pos'] = settings['news.social_share_pos']
        #site.settings.destroy 'news.social_share_pos'
      end

      if settings['news.social_share_networks'].present?
        ext.settings['social_share_networks_'] = settings['news.social_share_networks']
        #site.settings.destroy 'news.social_share_networks'
      end

      if settings['news.facebook_comments'].present?
        ext.settings['facebook_comments_'] = settings['news.facebook_comments']
        #ext.settings.destroy :social_share_networks_
      end
      ext.save
    end
  end
end

include Rails.application.routes.url_helpers

class MigrateUrlsFromBannersAndMenus < ActiveRecord::Migration
  # Cria url atravez da página cadastrada já que
  # anteriormente o campo era nil
  def self.up
    Banner.where('page_id IS NOT NULL').each do |banner|
      banner.url = url_for(
        controller: 'pages',
        action: 'show',
        site_id: banner.site.name,
        id: banner.page_id,
        only_path: true
      )
      banner.save!
    end

    Menu.where('page_id IS NOT NULL').each do |menu|
      next if menu.sites.first == nil
      menu.link = url_for(
        controller: 'pages',
        action: 'show',
        site_id: menu.sites.first.name,
        id: menu.page_id,
        only_path: true
      )
      menu.save!
    end
  end

  def self.down
  end
end

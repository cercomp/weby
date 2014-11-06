class MigrateEvents < ActiveRecord::Migration
  class Page < ActiveRecord::Base
    self.inheritance_column = nil
  end
  class Page::I18ns < ActiveRecord::Base
  end

  def up
    Page.where(type: 'Event').find_each do |page|
      event = Calendar::Event.create!(
        site_id: page.site_id,
        repository_id: page.repository_id,
        user_id: page.author_id,
        begin_at: page.event_begin,
        end_at: page.event_end,
        email: page.event_email,
        url: page.url,
        kind: page.kind,
        deleted_at: page.deleted_at,
        view_count: page.view_count,
        i18ns_attributes: Page::I18ns.where(page_id: page.id).map do |i18n|
                 {
                   locale_id: i18n.locale_id,
                   name: i18n.title,
                   place: page.local
                 }
               end
      )
    end
  end
end

# This migration comes from calendar (originally 20141104160544)
class MigrateEvents < ActiveRecord::Migration
  class Page < ApplicationRecord
    self.inheritance_column = nil
    has_many :i18ns, class_name: 'Page::I18ns',
                   foreign_key: :page_id,
                   dependent: :delete_all
  end
  class Page::I18ns < ApplicationRecord
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
                   place: page.local.present? ? page.local : 'Local'
                 }
               end
      )
      page.destroy
    end
  end
end

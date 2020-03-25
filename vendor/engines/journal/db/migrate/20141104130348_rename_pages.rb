class RenamePages < ActiveRecord::Migration
  class Page < ApplicationRecord
    self.inheritance_column = nil
  end

  def up
    Page.where(publish: true).update_all(status: 'published')
    Page.where(publish: false).update_all(status: 'draft')

    rename_column :pages, :author_id, :user_id
    remove_column :pages, :kind, :string
    remove_column :pages, :event_begin, :datetime
    remove_column :pages, :event_end, :datetime
    remove_column :pages, :event_email, :string
    remove_column :pages, :subject, :string
    remove_column :pages, :align, :string
    remove_column :pages, :type, :string
    remove_column :pages, :size, :string
    remove_column :pages, :publish, :boolean

    rename_table :pages, :journal_news

    rename_column :page_i18ns, :page_id, :journal_news_id

    rename_table :page_i18ns, :journal_news_i18ns
  end

  def down
    rename_table :journal_news, :pages

    rename_column :pages, :user_id, :author_id
    add_column :pages, :kind, :string
    add_column :pages, :event_begin, :datetime
    add_column :pages, :event_end, :datetime
    add_column :pages, :event_email, :string
    add_column :pages, :subject, :string
    add_column :pages, :align, :string
    add_column :pages, :type, :string
    add_column :pages, :size, :string
    add_column :pages, :publish, :boolean, default: false

    Page.reset_column_information
    Page.where(status: 'published').update_all(publish: true)
    Page.where(status: ['draft', 'review']).update_all(publish: false)

    rename_table :journal_news_i18ns, :page_i18ns

    rename_column :page_i18ns, :journal_news_id, :page_id
  end
end

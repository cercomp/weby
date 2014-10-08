# This migration comes from journal (originally 20140804200259)
class CreateJournalNewsI18ns < ActiveRecord::Migration
  def change
    create_table :journal_news_i18ns do |t|
      t.integer  :journal_news_id
      t.integer  :locale_id
      t.string   :title
      t.text     :summary
      t.text     :text

      t.timestamps
    end

    add_index :journal_news_i18ns, :journal_news_id
    add_index :journal_news_i18ns, :locale_id

    add_foreign_key :journal_news_i18ns, :journal_news
    add_foreign_key :journal_news_i18ns, :locales
  end
end

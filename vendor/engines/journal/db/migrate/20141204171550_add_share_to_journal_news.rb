class AddShareToJournalNews < ActiveRecord::Migration
  def up
    create_join_table :journal_news, :sites do |t|
       t.primary_key :id
       t.index [:journal_news_id, :site_id]
       t.integer :position
       t.boolean  "front",         default: false
       t.datetime :date_begin_at
       t.datetime :date_end_at
       t.datetime :created_at
       t.datetime :updated_at
    end
      execute <<-SQL
        INSERT INTO journal_news_sites (journal_news_id, site_id, position, front, date_begin_at, date_end_at, created_at, updated_at)
        SELECT id, site_id, position, front, date_begin_at, date_end_at, created_at, updated_at
        FROM journal_news
      SQL
  end
end

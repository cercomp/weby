class AddShareToJournalNews < ActiveRecord::Migration
  def up
    create_join_table :journal_news, :sites do |t|
       t.index [:journal_news_id, :site_id]
       t.integer :position
    end
#      execute <<-SQL
#        INSERT INTO news_sites (news_id, site_id, position)
#        SELECT id, site_id, position
#        FROM journal_news
      #SQL
  end
end

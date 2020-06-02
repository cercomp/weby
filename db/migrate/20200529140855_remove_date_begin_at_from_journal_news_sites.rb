class RemoveDateBeginAtFromJournalNewsSites < ActiveRecord::Migration[5.2]
  def change

    reversible do |dir|
      dir.up do
        ActiveRecord::Base.connection.execute("
          UPDATE journal_news AS n
          SET date_begin_at = ns.date_begin_at,
              date_end_at = ns.date_end_at
          FROM journal_news_sites AS ns
          WHERE ns.journal_news_id = n.id AND ns.site_id = n.site_id")
      end
      dir.down do
        #
      end
    end

    remove_column :journal_news_sites, :date_begin_at, :datetime
    remove_column :journal_news_sites, :date_end_at, :datetime
  end
end

class AddDraftBodyToJournalNews < ActiveRecord::Migration
  def change
    add_column :journal_news_i18ns, :draft_body, :text
    add_column :journal_news_i18ns, :draft_summary, :text
  end
end

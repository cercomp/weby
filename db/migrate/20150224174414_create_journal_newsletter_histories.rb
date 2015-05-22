class CreateJournalNewsletterHistories < ActiveRecord::Migration
  def change
    create_table :journal_newsletter_histories do |t|
      t.integer :site_id
      t.integer :news_id
      t.integer :user_id
      t.text :emails

      t.timestamps
    end
  end
end

# This migration comes from journal (originally 20140804184706)
class CreateJournalNews < ActiveRecord::Migration
  def change
    create_table :journal_news do |t|
      t.integer  :site_id
      t.integer  :repository_id
      t.integer  :user_id
      t.datetime :date_begin_at
      t.datetime :date_end_at
      t.string   :status
      t.string   :url
      t.string   :source
      t.integer  :position
      t.boolean  :front
      t.datetime :deleted_at, default: nil
      t.integer  :view_count, default: 0

      t.timestamps
    end

    add_index :journal_news, :user_id
    add_index :journal_news, :site_id
    add_index :journal_news, :repository_id
    
    add_foreign_key :journal_news, :users
    add_foreign_key :journal_news, :sites
    add_foreign_key :journal_news, :repositories
  end
end

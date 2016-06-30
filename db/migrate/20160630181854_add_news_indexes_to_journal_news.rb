class AddNewsIndexesToJournalNews < ActiveRecord::Migration
  def up
    Weby::generate_search_indexes
  end

  def down
    Weby::drop_search_indexes
  end
end

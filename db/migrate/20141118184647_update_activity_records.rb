class UpdateActivityRecords < ActiveRecord::Migration
  def up
    ActivityRecord.where(controller: 'page').update_all(controller: 'news')
    ActivityRecord.where(loggeable_type: 'Page').update_all(loggeable_type: 'Journal::News')
    execute "update taggings set taggable_type='Journal::News' where taggable_type='Page';"
  end

  def down
    ActivityRecord.where(controller: 'news').update_all(controller: 'page')
    ActivityRecord.where(loggeable_type: 'Journal::News').update_all(loggeable_type: 'Page')
    execute "update taggings set taggable_type='Page' where taggable_type='Journal::News';"
  end
end

class AddDifferencesToActivityRecords < ActiveRecord::Migration[8.1]
  def change
    add_column :activity_records, :differences, :jsonb, default: {}
  end
end

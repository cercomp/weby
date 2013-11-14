class CreateActivityRecords < ActiveRecord::Migration
  def change
    create_table :activity_records do |t|
      t.integer :user_id
      t.integer :site_id
      t.string :browser
      t.string :ip_address
      t.string :controller
      t.string :action
      t.text :params
      t.string :note
      t.references :loggeable, polymorphic: true
      t.timestamps
    end
  end
end

class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :title
      t.text :body
      t.references :user
      t.timestamps
    end
  end
end

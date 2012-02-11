class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.string :name
      t.string :email
      t.string :subject
      t.text :message
      t.integer :site_id

      t.timestamps
    end
  end

  def self.down
    drop_table :feedbacks
  end
end

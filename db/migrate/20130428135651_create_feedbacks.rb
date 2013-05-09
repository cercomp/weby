class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.string   :name
      t.string   :email
      t.string   :subject
      t.text     :message
      t.integer  :site_id

      t.timestamps
    end
    
    add_index :feedbacks, :site_id

    add_foreign_key :feedbacks, :sites
  end
end

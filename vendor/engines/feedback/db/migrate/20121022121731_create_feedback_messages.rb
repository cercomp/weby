class CreateFeedbackMessages < ActiveRecord::Migration
  def change
    create_table :feedback_messages do |t|
      t.string :name
      t.string :email
      t.string :subject
      t.text :message
      t.references :site
      t.string :to

      t.timestamps
    end
    add_index :feedback_messages, :site_id
  end
end

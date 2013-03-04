class CreateViews < ActiveRecord::Migration
  def change
    create_table :views do |t|
      t.references :site
      t.integer :viewable_id
      t.string :viewable_type
      t.integer :user_id
      t.string :request_path
      t.text :user_agent
      t.string :session_hash
      t.string :ip_address
      t.text :referer
      t.text :query_string

      t.timestamps
    end
    add_index :views, :site_id
    add_index :views, :viewable_id
  end
end

class CreateUserLoginHistories < ActiveRecord::Migration
  def change
    create_table :user_login_histories do |t|
      t.integer "user_id", null: false
      t.string  "login_ip"
      t.string  "browser"
      t.string  "platform"
      t.timestamps
    end

    add_index :user_login_histories, :user_id

    add_foreign_key :user_login_histories, :users
  end
end

class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :login
      t.string   :email
      t.string   :crypted_password
      t.string   :password_salt
      t.string   :persistence_token
      t.string   :single_access_token
      t.string   :perishable_token
      t.integer  :login_count,
        default: 0
      t.integer  :failed_login_count,
        default: 0
      t.datetime :last_request_at
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.string   :current_login_ip
      t.string   :last_login_ip
      t.string   :theme
      t.boolean  :status,
        default: false
      t.boolean  :is_admin,
        default: false
      t.string   :first_name
      t.string   :last_name
      t.string   :phone
      t.string   :mobile
      t.string   :register
      t.integer  :locale_id

      t.timestamps
    end
    
    add_index :users, :locale_id
    
    add_foreign_key :users, :locales
  end
end

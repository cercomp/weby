class AddDeviseToUsers < ActiveRecord::Migration
  def self.up

    rename_column :users, :crypted_password, :encrypted_password
    rename_column :users, :login_count, :sign_in_count
    rename_column :users, :current_login_at, :current_sign_in_at
    rename_column :users, :last_login_at, :last_sign_in_at
    rename_column :users, :current_login_ip, :current_sign_in_ip
    rename_column :users, :last_login_ip, :last_sign_in_ip
    rename_column :users, :failed_login_count, :failed_attempts
    
    remove_column :users, :persistence_token
    remove_column :users, :perishable_token
    remove_column :users, :single_access_token
    remove_column :users, :last_request_at

    change_table(:users) do |t|
      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

    end
    execute "UPDATE users SET confirmed_at = created_at, confirmation_sent_at = created_at WHERE status = TRUE"

    #unrelated
    remove_column :users, :theme
    remove_column :users, :status
    remove_column :users, :register

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :unlock_token,         unique: true
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end

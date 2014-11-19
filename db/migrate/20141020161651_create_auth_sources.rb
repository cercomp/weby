class CreateAuthSources < ActiveRecord::Migration
  def change
    create_table :auth_sources do |t|
      t.integer :user_id
      t.string :source_type
      t.string :source_login

      t.timestamps
    end
  end
end

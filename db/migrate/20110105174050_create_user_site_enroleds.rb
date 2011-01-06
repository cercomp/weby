class CreateUserSiteEnroleds < ActiveRecord::Migration
  def self.up
    create_table :user_site_enroleds do |t|
      t.integer :user_id
      t.integer :site_id
      t.integer :role_id

      t.timestamps
    end
  end

  def self.down
    drop_table :user_site_enroleds
  end
end

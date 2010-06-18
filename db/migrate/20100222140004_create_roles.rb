class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name

      t.timestamps
    end
    Role.create :name => 'manager'
  end

  def self.down
    drop_table :roles
  end
end

class RemoveColumnsFromSettings < ActiveRecord::Migration
  def self.up
    remove_column :settings, :group
    remove_column :settings, :position
  end

  def self.down
    add_column :settings, :group, :string
    add_column :settings, :position, :integer
  end
end

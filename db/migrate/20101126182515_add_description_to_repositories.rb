class AddDescriptionToRepositories < ActiveRecord::Migration
  def self.up
    add_column :repositories, :description, :string
  end

  def self.down
    remove_column :repositories, :description
  end
end

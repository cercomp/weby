class ChangePositionPagesToInteger < ActiveRecord::Migration
  def self.up
    remove_column :pages, :position
    add_column :pages, :position, :integer
  end

  def self.down
    remove_column :pages, :position
    add_column :pages, :position, :string
  end
end

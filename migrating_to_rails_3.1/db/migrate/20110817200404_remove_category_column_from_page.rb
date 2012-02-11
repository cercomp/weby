class RemoveCategoryColumnFromPage < ActiveRecord::Migration
  def self.up
    remove_column :pages, :category
  end

  def self.down
    add_column :pages, :category, :string
  end
end

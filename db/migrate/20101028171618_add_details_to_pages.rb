class AddDetailsToPages < ActiveRecord::Migration
  def self.up
    change_column :pages, :text, :text
  end

  def self.down
    change_column :pages, :text, :string
  end
end

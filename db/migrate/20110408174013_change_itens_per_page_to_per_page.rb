class ChangeItensPerPageToPerPage < ActiveRecord::Migration
  def self.up
    remove_column :sites, :itens_per_page
    add_column :sites, :per_page, :string, :default => '5, 15, 30, 50, 100'
  end

  def self.down
    remove_column :sites, :per_page
    add_column :sites, :itens_per_page, :string
  end
end

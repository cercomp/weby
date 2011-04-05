class AddItensPerPageToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :itens_per_page, :string
  end

  def self.down
    remove_column :sites, :itens_per_page
  end
end

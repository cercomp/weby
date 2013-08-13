class AddDomainToSites < ActiveRecord::Migration
  def change
    add_column :sites, :domain, :string
  end
end

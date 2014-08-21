class AddTitleToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :title, :string
    add_column :repositories, :legend, :string
  end
end

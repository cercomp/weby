class AddHiddenToGroupings < ActiveRecord::Migration
  def change
    add_column :groupings, :hidden, :boolean
  end
end

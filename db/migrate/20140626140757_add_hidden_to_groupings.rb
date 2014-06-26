class AddHiddenToGroupings < ActiveRecord::Migration
  def change
    add_column :groupings, :hidden, :boolean, default: false
  end
end

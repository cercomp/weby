class RenameCssesToStyles < ActiveRecord::Migration
  def change
    rename_table :csses, :styles
  end
end

class RenameComponentColumn < ActiveRecord::Migration
  def change
    rename_column :site_components, :component, :name
  end
end

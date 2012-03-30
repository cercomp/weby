class RenameComponentColumn < ActiveRecord::Migration
  def change
    rename_column :site_components, :component, :component_name
  end
end

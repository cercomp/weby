class ChangeSitesToDefineSizes < ActiveRecord::Migration
  def self.up
    # Colunas renomeadas
    rename_column :sites, :cover_id, :top_banner_id
    # Colunas adicionadas
    add_column :sites, :top_banner_width, :integer
    add_column :sites, :top_banner_height, :integer
    add_column :sites, :body_width, :integer
  end

  def self.down
    rename_column :sites, :top_banner_id, :cover_id
    remove_column :sites, :top_banner_width
    remove_column :sites, :top_banner_height
    remove_column :sites, :body_width
  end
end

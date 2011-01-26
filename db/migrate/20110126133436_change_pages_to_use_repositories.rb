class ChangePagesToUseRepositories < ActiveRecord::Migration
  def self.up
    # Colunas removidas
    remove_column :pages, :image_file_name
    remove_column :pages, :image_content_type
    remove_column :pages, :image_file_size
    remove_column :pages, :image_updated_at
    remove_column :pages, :image
    remove_column :pages, :text_image
    remove_column :pages, :text_clob
    # Colunas renomeadas
    rename_column :pages, :date_begin, :date_begin_at
    rename_column :pages, :date_end, :date_end_at
    # Colunas alteradas
    change_column :pages, :date_begin_at, :datetime
    change_column :pages, :date_end_at, :datetime
    # Colunas adicionadas
    add_column :pages, :repository_id, :integer
  end

  def self.down
    add_column :pages, :image_file_name, :string
    add_column :pages, :image_content_type, :string
    add_column :pages, :image_file_size, :integer
    add_column :pages, :image_updated_at, :datetime
    add_column :pages, :image, :string
    add_column :pages, :text_image, :string
    add_column :pages, :text_clob, :string
    rename_column :pages, :date_begin_at, :date_begin
    rename_column :pages, :date_end_at, :date_end
    change_column :pages, :date_begin, :date
    change_column :pages, :date_end, :date
    remove_column :pages, :repository_id
  end
end

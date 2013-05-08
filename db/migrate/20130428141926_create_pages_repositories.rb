class CreatePagesRepositories < ActiveRecord::Migration
  def change
    create_table :pages_repositories do |t|
      t.integer  :page_id
      t.integer  :repository_id
    end
    
    add_index :pages_repositories, :page_id
    add_index :pages_repositories, :repository_id

    add_foreign_key :pages_repositories, :pages
    add_foreign_key :pages_repositories, :repositories
  end
end
